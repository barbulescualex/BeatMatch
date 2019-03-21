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
    private var values = [Float]()
    
    public func rms(from buffer: AVAudioPCMBuffer, with bufferSize: UInt, cell: MidiCell?){
        guard let channelData = buffer.floatChannelData?[0] else {return}
        var val = Float(0);
        
        vDSP_vsq(channelData, 1, channelData, 1, bufferSize) //square
        vDSP_meanv(channelData, 1, &val, bufferSize) //mean
        val = val + 0.3
        if val == 0.3{ //makes sure it always ends up on 0.3 scale size
            cell?.cellIsPlaying = false
            if normalSet {
                values = []
                return
            } else {
                normalSet = true
            }
        } else {
            normalSet = false
        }
        if (val > 0.6) {val = 0.6}
        if (cell != nil){
            print(val, cell?.sound?.rawValue)
        } else {
            print(val, "MAIN MIXER")
        }
        values.append(val)
        if values.count > 2 {
            let current = val
            let previous = values[values.count-2]
            let inbetween = (current + previous)/2
            print(inbetween, "INBETWEEN")
            visualizer?.scaleValue = inbetween
        }
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
