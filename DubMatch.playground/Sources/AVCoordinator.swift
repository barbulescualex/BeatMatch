import UIKit

//Audio Visual Coordinator
public final class AVCoordinator {
    static let shared = AVCoordinator()
    public var cells : [MidiCell] = []
    
    public func play(from text: String){
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
        let cell = cells[index-1]
        cell.play()
        cell.animate()
    }
}
