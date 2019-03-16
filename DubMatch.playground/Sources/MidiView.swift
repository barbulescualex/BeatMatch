import UIKit
import PlaygroundSupport

public class MidiView : UIView {
    lazy var snare = MidiButton(sound: Sounds.snare)
    lazy var ghostSnare = MidiButton(sound: Sounds.ghostSnare)
    lazy var bass = MidiButton(sound: Sounds.bass)
    lazy var hiHat = MidiButton(sound: Sounds.hiHat)
    lazy var chime = MidiButton(sound: Sounds.chime)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupMidi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupMidi(){
        backgroundColor = .white
        let stack = UIStackView(frame: frame)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        topStack.addArrangedSubview(hiHat)
        topStack.addArrangedSubview(chime)
        
        let bottomStack = UIStackView()
        bottomStack.axis = .horizontal
        bottomStack.distribution = .fillEqually
        bottomStack.addArrangedSubview(bass)
        bottomStack.addArrangedSubview(snare)
        bottomStack.addArrangedSubview(ghostSnare)
        
        stack.addArrangedSubview(topStack)
        stack.addArrangedSubview(bottomStack)
    }
    
}

