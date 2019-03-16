import UIKit
import PlaygroundSupport

public class MidiView : UIView {
    lazy var parentStack : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var snare =  MidiButton(frame: , sound: "chime")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

