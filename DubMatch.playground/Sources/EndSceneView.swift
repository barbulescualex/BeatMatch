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

protocol EndSceneViewDelegate : AnyObject {
    func closeView(_ sender: EndSceneView)
}

public class EndSceneView : UIView, UIGestureRecognizerDelegate {
    var type : EndMessage!
    
    weak var delegate : EndSceneViewDelegate?
    
    let backgroundView : UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let viewArea : UIView =  {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public required init(type : EndMessage) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        showAnimate()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        //for pop up look
        layer.zPosition = 100
        clipsToBounds = true
        
        //background view
        addSubview(backgroundView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(outsidePressed(_:)))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
        
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        //view area
        addSubview(viewArea)
        viewArea.topAnchor.constraint(equalTo: topAnchor, constant: 200).isActive = true
        viewArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -200).isActive = true
        viewArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        viewArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
    
        //title label
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = type.prefixEmoji + type.title + "!" + type.suffixEmoji
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        viewArea.addSubview(label)
        label.centerXAnchor.constraint(equalTo: viewArea.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: viewArea.centerYAnchor).isActive = true
    }
    
    @objc func outsidePressed(_ sender: UIGestureRecognizer){
        leaveAnimate()
    }
    
    //Animations
    func showAnimate(){
        viewArea.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        viewArea.alpha = 0.0
        UIView.animate(withDuration: 0.125, animations: {
            self.viewArea.alpha = 1.0
            self.viewArea.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        }, completion: { _ in
            UIView.animate(withDuration: 0.075, animations: {
                self.viewArea.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { _ in
                
            })
        })
    }
    
    func leaveAnimate(){
        //viewArea.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.1, animations: {
            self.viewArea.frame = CGRect(x: 0, y: 2000, width: self.viewArea.frame.size.width, height: self.viewArea.frame.size.height)
            self.backgroundView.backgroundColor = .clear
        }) { _ in
            self.delegate?.closeView(self)
        }
    }
}