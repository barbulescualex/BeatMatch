import UIKit


public enum EmotionMessage : String, CaseIterable {
    case NICE
    case AWESOME
    case SWEET
    case DOPE
    case EASY
    
    case AWE
    
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
        case .AWE:
            return "😢"
        }
    }
}

public class EmotionView : UIView {
    var message : EmotionMessage!
    public required init(message : EmotionMessage) {
        self.message = message
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        layer.zPosition = 100
        translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = message.rawValue + "!" + message.emoji
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
