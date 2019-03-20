import UIKit

public enum EndMessage {
    case over
    case win
    
    var title : String {
        switch self {
        case .win:
            return "YOU WIN!"
        case .over:
            return "GAME OVER"
        }
    }
    
    var prefixEmoji : String {
        switch self {
        case .win:
            return "🤙"
        case .over:
            return "😫"
        }
    }
    
    var suffixEmoji : String {
        switch self {
        case .win:
            return "🎉"
        case .over:
            return "😢"
        }
    }
}

public class EndSceneView : UIView {
    var type : EndMessage!
    
    public required init(type : EndMessage) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = type.prefixEmoji + type.title + "!" + type.suffixEmoji
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
