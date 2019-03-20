import UIKit

//Audio Visual Coordinator
public final class AVCoordinator {
    static let shared = AVCoordinator()
    public var cells : [MidiCell] = [] {
        didSet {
            for cell in cells {
                print(cell.sound!.rawValue)
            }
        }
    }
}
