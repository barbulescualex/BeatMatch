import UIKit
import AVFoundation
import Accelerate

//Audio Visual Coordinator
public final class AVCoordinator {
    static let shared = AVCoordinator()
    public var cells : [MidiCell] = []
    
    
    //Playing
    public var isPlaying = false
    
    public func play(from text: String, completion: @escaping()->()){
        isPlaying = true
        var iterator = 0
        let count = text.count
        var chars = [Character]()
        for char in text {
            chars.append(char)
        }

        Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 0.4)!, repeats: true) { (timer) in
            self.playHelper(play: chars[iterator])
            iterator = iterator + 1
            if (iterator == count) {
                timer.invalidate()
                self.isPlaying = false
                completion()
            }
        }
    }
    
    fileprivate func playHelper(play char: Character){
        let str = String(char)
        if str == " " {
            return
        }
        
        guard let index = Int(str) else {return}
        if !cells.indices.contains(index) {return}
        let cell = cells[index]
        cell.play()
        cell.animate()
    }
    
    
    //Testing
    public var isTesting = false {
        didSet {
            if !isTesting { //clear comparison strings
                stringToTestFor = nil
                inputPressStream = nil
            }
        }
    }
    
    public var stringToTestFor : String? {
        didSet{
            guard let string = stringToTestFor else {return}
            isTesting = true
            let str = string.components(separatedBy: .whitespaces)
            stringToTestFor = str.joined()
        }
    }
    
    private var inputPressStream : String? {
        didSet{
            if inputPressStream != nil && isTesting {
                for i in 0..<inputPressStream!.count {
                    let inputIndex = inputPressStream!.index(inputPressStream!.startIndex, offsetBy: i)
                    let testingIndex = stringToTestFor!.index(stringToTestFor!.startIndex, offsetBy: i)
                    if inputPressStream![inputIndex] != stringToTestFor![testingIndex]{
                        testingEnded(withResult: false)
                        return
                    }
                }
                
                if inputPressStream?.count == stringToTestFor?.count {
                    testingEnded(withResult: true)
                }
            }
        }
    }
    
    private func testingEnded(withResult result: Bool){
        isTesting = false
        if result {
             NotificationCenter.default.post(name: .passed, object: nil)
        } else {
            NotificationCenter.default.post(name: .failed, object: nil)
        }
    }
    
    //Visualizer
    public var visualizer : Visualizer?
    private var normalSet = false
    private var values : [Float] = [0.3]
    
    
    public var buffer : AVAudioPCMBuffer? {
        didSet{
            let thread = Thread(target: self, selector: #selector(compute), object: nil)
            thread.start()
        }
    }
    
    @objc func compute(){
        guard let channelData = buffer?.floatChannelData?[0] else {return}
        var val = Float(0);
        
        //RMS
        vDSP_measqv(channelData, 1, &val, 2048)
        
        //check for done state
        if val < 0.00009 { //makes sure it always ends up on 0.3 scale size
            if normalSet {
                values = [0.3]
                return
            } else {
                normalSet = true
            }
        } else {
            normalSet = false
        }
        
        //FFT
        let frameCount = 2048
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        let windowSize = bufferSizePOT
        var transferBuffer = [Float](repeating: 0, count: windowSize)
        var window = [Float](repeating: 0, count: windowSize)
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul((buffer!.floatChannelData?.pointee)!, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        // Transforming the [Float] buffer into a UnsafePointer<Float> object for the vDSP_ctoz method
        // And then pack the input into the complex buffer (output)
        let temp = UnsafePointer<Float>(transferBuffer)
        temp.withMemoryRebound(to: DSPComplex.self,
                               capacity: transferBuffer.count) {
                                vDSP_ctoz($0, 2, &output, 1, vDSP_Length(inputCount))
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        var magnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))
        
        // Normalising
        var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_vsmul(magnitudes, 1, [2.0 / Float(inputCount)],
                   &normalizedMagnitudes, 1, vDSP_Length(inputCount))
        
        vDSP_destroy_fftsetup(fftSetup)
        
        
        print("MAGNITUDES : ", magnitudes.count , " :",magnitudes)
        
        //Adjust values to 2 decimal places
        if val < 0.0009 {
            val = val*100
        } else if val < 0.009 {
            val = val*10
        }
        if val < 0.05 && !normalSet {
            val = 0.05
        }
        
        val = val + 0.3
        
        if (val > 0.5) {val = 0.5}
        values.append(val)
        
        print(Thread.current, "In RMS")
        
        //interpolation
        if values.count >= 2  {
            let current = val
            let previous = values[values.count-2]
            
            let three = (current + previous)/2
            let two = (three + previous)/2
            let one = (two + previous)/2
            let four = (three + current)/2
            let five = (four + current)/2
            
            visualizer?.scaleValue = one
            print(one)
            visualizer?.scaleValue = two
            print(two)
            visualizer?.scaleValue = three
            print(three)
            visualizer?.scaleValue = four
            print(four)
            visualizer?.scaleValue = five
            print(five)
        }
        print(val, "VAL")
        visualizer?.scaleValue = val
    }
}

extension AVCoordinator : MidiCellDelegate {
    func pressed(_ cell: MidiCell) {
        if !isTesting {return}
        guard let index = cells.firstIndex(of: cell) else {return}
        print("found index of cell from delegate")
        let char = Character(String(index))
        if inputPressStream != nil {
            inputPressStream!.append(char)
        } else {
            inputPressStream = String(char)
        }
    }
}
