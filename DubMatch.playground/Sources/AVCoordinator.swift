import UIKit

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
    private var testing = false
    
    public var stringToTestFor : String? {
        didSet{
            guard let string = stringToTestFor else {return}
            testing = true
            let str = string.components(separatedBy: .whitespaces)
            stringToTestFor = str.joined()
        }
    }
    
    private var inputPressStream : String? {
        didSet{
            if inputPressStream != nil && testing {
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
        testing = false
        stringToTestFor = nil
        inputPressStream = nil
        
        if result {
             NotificationCenter.default.post(name: .passed, object: nil)
        } else {
            NotificationCenter.default.post(name: .failed, object: nil)
        }
    }
    
    //Visualizer
    
}

extension AVCoordinator : MidiCellDelegate {
    func pressed(_ cell: MidiCell) {
        if !testing {return}
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
