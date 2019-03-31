import UIKit
import AVFoundation


protocol EndSceneViewDelegate : AnyObject {
    func closeView(_ sender: EndSceneView)
}

public class EndSceneView : UIView, UIGestureRecognizerDelegate {
    //MARK:- VARS
    private var type : EndMessage!
    private var player : AVAudioPlayer?
    private var canExit = true
    
    weak var delegate : EndSceneViewDelegate?
    
    
    //MARK:- VIEW COMPONENTS
    private let backgroundView : UIView = { //transparent overlay
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let viewArea : UIView =  { //display area
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK:- INIT
    public required init(type : EndMessage) {
        self.type = type
        super.init(frame: .zero)
        playSound()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        showAnimate()
    }
    
    //MARK:- FUNCTIONS
    fileprivate func playSound(){
        guard let url = Bundle.main.url(forResource: type.sound, withExtension: type.fileExtension) else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            canExit = false
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { //allow time for sound to complete
                self.canExit = true
            }
        } catch {
            print(error)
        }
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
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        
        //content
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.layer.cornerRadius = 10
        content.clipsToBounds = true
        content.backgroundColor = .white
        
        content.layer.shadowColor = UIColor.black.cgColor
        content.layer.shadowRadius = 3.0
        content.layer.shadowOpacity = 1.0
        content.layer.shadowOffset = CGSize(width: 4, height: 4)
        content.layer.masksToBounds = false
        
        //content label
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 20)
        contentLabel.textColor = .black
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        if type == .over {
            contentLabel.text = "Try again 😜! You can always make the game easier by changing the input parameters for the Game object 😎"
        } else {
            contentLabel.text = "Thanks for stopping by my playground, see you at WWDC 2019! 👋🏻☺️"
        }
        
        viewArea.addSubview(label)
        label.centerXAnchor.constraint(equalTo: viewArea.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: viewArea.topAnchor, constant: 5).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        viewArea.addSubview(content)
        content.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7.5).isActive = true
        content.trailingAnchor.constraint(equalTo: viewArea.trailingAnchor, constant: -7.5).isActive = true
        content.leadingAnchor.constraint(equalTo: viewArea.leadingAnchor, constant: 7.5).isActive = true
        content.bottomAnchor.constraint(equalTo: viewArea.bottomAnchor, constant: -7.5).isActive = true
        
        content.addSubview(contentLabel)
        contentLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 5).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -5).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 5).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -5).isActive = true
        
    }
    
    @objc func outsidePressed(_ sender: UIGestureRecognizer){
        if canExit {
            leaveAnimate()
        }
    }
    
    //MARK:- ANIMATIONS
    fileprivate func showAnimate(){
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
    
    fileprivate func leaveAnimate(){
        UIView.animate(withDuration: 0.1, animations: {
            self.viewArea.frame = CGRect(x: 0, y: 2000, width: self.viewArea.frame.size.width, height: self.viewArea.frame.size.height)
            self.backgroundView.backgroundColor = .clear
        }) { _ in
            self.delegate?.closeView(self)
        }
    }
}
