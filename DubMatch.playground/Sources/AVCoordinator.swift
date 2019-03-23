import UIKit
import AVFoundation
import Accelerate

//Audio Visual Coordinator
public final class AVCoordinator {
    static let shared = AVCoordinator()
    public var cells : [MidiCell] = []{
        didSet{
            var sounds = [String]()
            for cell in cells {
                sounds.append(cell.sound!.rawValue)
            }
            print("CELLS: ", sounds)
        }
    }
    public var cellAccurateIndexes : [Int] = []{
        didSet{
            print("INDEXES: ", cellAccurateIndexes)
        }
    }
    
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
        guard let accurateIndex = cellAccurateIndexes.firstIndex(of: index) else {return}
        if !cells.indices.contains(accurateIndex) {return}
        let cell = cells[accurateIndex]
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
        
        //fft setup
        let fftSetup = vDSP_create_fftsetup(11, Int32(kFFTRadix2))
        
        //output setup
        var realp = [Float](repeating: 0, count: 2048)
        var imagp = [Float](repeating: 0, count: 2048)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        //pack the channelData into output for FFT
        channelData.withMemoryRebound(to: DSPComplex.self, capacity: 1024) {
            vDSP_ctoz($0, 2, &output, 1, 1024)
        }

        //fft
        vDSP_fft_zrip(fftSetup!, &output, 1, 11, Int32(FFT_FORWARD))
        
        //converting real and imaginary parts into magnitudes
        var magnitude = [Float](repeating: 0, count: 1024)
        vDSP_zvmags(&output, 1, &magnitude, 1, 1024) //a^2 + b^2
        
        var normalizingFactor : Float = 1.0/(2*2048)
        //normalizing
        var normalizedMagnitude = [Float](repeating: 0, count: 1024)
        vDSP_vsmul(&magnitude, 1, &normalizingFactor, &normalizedMagnitude, 1, 1024)
        
        visualizer?.lineMagnitudes = normalizedMagnitude
        
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
        
        //interpolation
        if values.count >= 2  {
            let current = val
            let previous = values[values.count-2]
            
            let three = (current + previous)/2
            let two = (three + previous)/2
            let two5 = (two + three)/2
            let one = (two + previous)/2
            let zero5 = (previous + one)/2
            let one5 = (one + two)/2
            let four = (three + current)/2
            let three5 = (three + four)/2
            let five = (four + current)/2
            let four5 = (four + five)/2
            
            visualizer?.scaleValue = zero5
            visualizer?.scaleValue = one
            visualizer?.scaleValue = one5
            visualizer?.scaleValue = two
            visualizer?.scaleValue = two5
            visualizer?.scaleValue = three
            visualizer?.scaleValue = three5
            visualizer?.scaleValue = four
            visualizer?.scaleValue = four5
            visualizer?.scaleValue = five
        }
        visualizer?.scaleValue = val
    }
}

extension AVCoordinator : MidiCellDelegate {
    func pressed(_ cell: MidiCell) {
        if !isTesting {return}
        guard let index = cells.firstIndex(of: cell) else {return}
        let updatedIndex = cellAccurateIndexes[index]
        print("found index of cell from delegate")
        let char = Character(String(updatedIndex))
        if inputPressStream != nil {
            inputPressStream!.append(char)
        } else {
            inputPressStream = String(char)
        }
    }
}
