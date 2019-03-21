import UIKit
import AVFoundation

public class Game: UIViewController {
    //MARK:- VARS
    private var engine = AVAudioEngine()
    private var level = 1 {
        didSet{
            levelLabel.text = "Level: \(level)"
            UIView.animate(withDuration: 0.1, animations: {
                self.levelLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (_) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.levelLabel.transform = CGAffineTransform.identity
                })
            }
        }
    }
    private var levelPatterns = ["001 001 0010001","0321 0321 0303 0321","004121 444 333 13","041 041 04041 041 04"]
    
    //MARK:- VIEW COMPONENTS
    private lazy var levelLabel : UILabel = {
        let label = UILabel()
        label.text = "Level: 1"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var resetButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "restart")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(restart(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private var visualizer : Visualizer!
    private var midiView : MidiView!
    private var lifeBar = LifeBar()
    private var listensBar = ListensBar()
    private var listeningLabel = ListneningLabel()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        setupEngine()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(levelFailed(notification:)), name: .failed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(levelPassed(notification:)), name: .passed, object: nil)
        setupViews()
    }
    
    fileprivate func setupViews(){
        view.backgroundColor = .black
        
        //topstack
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .fillProportionally
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        resetButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        resetButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        topStack.addArrangedSubview(levelLabel)
        topStack.addArrangedSubview(resetButton)
        
        view.addSubview(topStack)
        topStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 3).isActive = true
        topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3).isActive = true
        topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -3).isActive = true
        topStack.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //visualizer
        visualizer = Visualizer(engine: engine)
        AVCoordinator.shared.visualizer = visualizer
        midiView = MidiView(engine: engine, vis: visualizer)
        view.addSubview(visualizer)
        view.addSubview(midiView)
        visualizer.topAnchor.constraint(equalTo: topStack.bottomAnchor).isActive = true
        visualizer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualizer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        midiView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        midiView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        midiView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let midiHeight = view.bounds.height*0.2
        midiView.heightAnchor.constraint(equalToConstant: midiHeight).isActive = true
        
        visualizer.bottomAnchor.constraint(equalTo: midiView.topAnchor).isActive = true
        
        //LifeBar
        view.addSubview(lifeBar)
        lifeBar.topAnchor.constraint(equalTo: topStack.bottomAnchor).isActive = true
        lifeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3).isActive = true
        lifeBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //ListensBar
        view.addSubview(listensBar)
        listensBar.delegate = self
        listensBar.bottomAnchor.constraint(equalTo: midiView.topAnchor, constant: -5).isActive = true
        listensBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        listensBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //ListeningLabel
        view.addSubview(listeningLabel)
        listeningLabel.isHidden = true
        listeningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        listeningLabel.bottomAnchor.constraint(equalTo: midiView.topAnchor, constant: -5).isActive = true
        listeningLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    fileprivate func setupEngine(){
        //setup engine
        _ = engine.mainMixerNode //initialzing the output node to be able to start the engine
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print(error)
        }
    }
    
    @objc func restart(_ sender: UIButton){
        if AVCoordinator.shared.isPlaying { return }
        AVCoordinator.shared.isTesting = false
        level = 1
        lifeBar.reset()
        listensBar.reset()
        listeningLabel.isHidden = true
    }
    
    @objc func levelFailed(notification: NSNotification){
        listeningLabel.isHidden = true
        print("level failed")
        lifeBar.minusOne()
        if (lifeBar.hearts == 0){//GAME OVER
            let gameOver = EndSceneView(type: .over)
            gameOver.delegate = self
            view.addSubview(gameOver)
            gameOver.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            gameOver.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            gameOver.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            gameOver.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else { //Awe:(
            let awe = EmotionView(message: .AWE)
            view.addSubview(awe)
            awe.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            awe.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            awe.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            awe.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            awe.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                awe.alpha = 1
                awe.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (_) in
                UIView.animate(withDuration: 0.2, animations: {
                    awe.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    awe.removeFromSuperview()
                    self.startListening()
                })
            }
        }
        
        
    }
    
    @objc func levelPassed(notification: NSNotification){
        listeningLabel.isHidden = true
        print("level passed")
        level = level + 1
        listensBar.reset()
        if(level == levelPatterns.count){//win!
            let win = EndSceneView(type: .over)
            win.delegate = self
            view.addSubview(win)
            win.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            win.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            win.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            win.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            let emotion = EmotionMessage.make(index: level)
            let yay = EmotionView(message: emotion)
            view.addSubview(yay)
            yay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            yay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            yay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            yay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            yay.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                yay.alpha = 1
                yay.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (_) in
                UIView.animate(withDuration: 0.2, animations: {
                    yay.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    yay.removeFromSuperview()
                })
            }
        }
    }
    
    fileprivate func startListening(){
        let pattern = levelPatterns[level-1]
        AVCoordinator.shared.stringToTestFor = pattern
        listeningLabel.isHidden = false
    }
    
}

extension Game : EndSceneViewDelegate {
    func closeView(_ sender: EndSceneView) {
        sender.removeFromSuperview()
        level = 1
        lifeBar.reset()
        listensBar.reset()
    }
}

extension Game : ListensBarDelegate {
    func listensBarTapped() {
        if AVCoordinator.shared.isTesting {
            //end testing, don't lose a life
            AVCoordinator.shared.isTesting = false
        }
        listeningLabel.isHidden = true
        let pattern = levelPatterns[level-1]
        AVCoordinator.shared.play(from: pattern) {
            self.startListening()
            self.listensBar.minusOne()
        }
    }
}

extension Notification.Name {
    static let passed = Notification.Name("passed")
    static let failed = Notification.Name("failed")
}
