import UIKit


public enum LevelMessage : String {
    case NICE
    case AWESOME
    case SWEET
    case DOPE
    case EASY
    
    var emoji : String {
        switch self {
        case .NICE:
            return "👍"
        case .AWESOME:
            return "💪"
        case .SWEET:
            return "😎"
        case .DOPE:
            return "😈"
        case .EASY:
            return "😴"
        }
    }
}

public class InterLevelView : UIView {
    var message : LevelMessage!
    public required init(message : LevelMessage) {
        self.message = message
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
        label.text = message.rawValue + "!" + message.emoji
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
