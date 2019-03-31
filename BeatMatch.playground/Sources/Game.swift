import UIKit
import AVFoundation

public class Game: UIViewController {
    //MARK:- Vars
    private var engine = AVAudioEngine()
    private var level = 1 {
        didSet{
            levelLabel.text = "Level: \(level)"
//            UIView.animate(withDuration: 0.1, animations: {
//                self.levelLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//            }) { (_) in
//                UIView.animate(withDuration: 0.1, animations: {
//                    self.levelLabel.transform = CGAffineTransform.identity
//                })
//            }
        }
    }
    private var levelPatterns = [String]()
    
    public override func viewDidLayoutSubviews() {
        if midiView == nil {
            return
        }
        print("invalidated layout")
        midiView.collectionView.collectionViewLayout.invalidateLayout()
    }
    
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
    private var lifeBar : LifeBar!
    private var listensBar : ListensBar!
    private var listeningLabel = ListneningLabel()
    
    //MARK:- Game Vars
    private var difficulty : Difficulty!
    private var lives = 5
    private var listens = 3
    
    //MARK:- Setup Functions
    public init(withDifficulty difficulty: Difficulty, withLives lives: Int?, withListensPerLevel listens: Int?) {
        self.difficulty = difficulty
        if let lives = lives, !(lives >= 10) {
            self.lives = lives
        }
        if let listens = listens, !(listens >= 5) {
            self.listens = listens
        }
        self.levelPatterns = difficulty.pattern
        super.init(nibName: nil, bundle: nil)
        setupEngine()
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(levelFailed(notification:)), name: .failed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(levelPassed(notification:)), name: .passed, object: nil)
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
        
        //visualizer & midiView
        visualizer = Visualizer(engine: engine)
        AVCoordinator.shared.visualizer = visualizer
        midiView = MidiView(engine: engine)
        view.addSubview(visualizer)
        view.addSubview(midiView!)
        visualizer.topAnchor.constraint(equalTo: topStack.bottomAnchor).isActive = true
        visualizer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualizer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        if let superview = view.superview {
            midiView!.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            midiView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0 ).isActive = true
        }
        midiView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        midiView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        midiView!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let midiHeight = view.bounds.height*0.2
        midiView!.heightAnchor.constraint(equalToConstant: midiHeight).isActive = true
        
        visualizer.bottomAnchor.constraint(equalTo: midiView!.topAnchor).isActive = true
        
        //LifeBar
        lifeBar = LifeBar(lives: lives)
        view.addSubview(lifeBar)
        lifeBar.topAnchor.constraint(equalTo: topStack.bottomAnchor).isActive = true
        lifeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3).isActive = true
        lifeBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //ListensBar
        listensBar = ListensBar(listens: listens)
        view.addSubview(listensBar)
        listensBar.delegate = self
        listensBar.bottomAnchor.constraint(equalTo: midiView!.topAnchor, constant: -5).isActive = true
        listensBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        listensBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //ListeningLabel
        view.addSubview(listeningLabel)
        listeningLabel.isHidden = true
        listeningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        listeningLabel.bottomAnchor.constraint(equalTo: midiView!.topAnchor, constant: -5).isActive = true
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
    
    //MARK:- Game Functions
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
        if (lifeBar.lives == 0){//GAME OVER
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
            UIView.animate(withDuration: 0.5, animations: {
                awe.alpha = 1
                awe.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
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
        if(level == levelPatterns.count){//win!
            let win = EndSceneView(type: .win)
            win.delegate = self
            view.addSubview(win)
            win.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            win.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            win.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            win.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            let emotion = EmotionMessage.make(index: level-1)
            let yay = EmotionView(message: emotion)
            view.addSubview(yay)
            yay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            yay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            yay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            yay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            yay.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                yay.alpha = 1
                yay.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    yay.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    yay.removeFromSuperview()
                    self.level = self.level + 1
                    self.listensBar.reset()
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
//MARK:- Delegates
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

public enum Difficulty {
    case baby
    case easy
    case normal
    case hard
    
    public var pattern : [String] {
        switch self {
        case .baby:
            return ["111","111","111","111","111"]
        case .easy:
            return ["001 001 0010001"]
        case .normal:
            return ["111"]
        case .hard:
            return ["1111"]
        }
    }
}

