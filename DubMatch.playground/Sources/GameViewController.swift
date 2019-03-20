import UIKit
import AVFoundation

public class GameViewController : UIViewController {
    //MARK:- VARS
    private var engine = AVAudioEngine()
    private var level = 0
    private var levelPatterns = ["001 001 0010001","0321 0321 0303 0321","004121 444 333 13","041 041 04041 041 04"]
    
    //MARK:- VIEW COMPONENTS
    private lazy var levelLabel : UILabel = {
        let label = UILabel()
        label.text = "Level:"
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
        listensBar.bottomAnchor.constraint(equalTo: midiView.topAnchor, constant: -5).isActive = true
        listensBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        listensBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
        let pattern = "001 001 0010001"
        AVCoordinator.shared.stringToTestFor = pattern
    }
    
    @objc func levelFailed(notification: NSNotification){
        let gameOver = EndSceneView(type: .over)
        gameOver.delegate = self
        view.addSubview(gameOver)
        gameOver.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gameOver.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gameOver.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gameOver.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func levelPassed(notification: NSNotification){
        print("level passed")
    }
    
}

extension GameViewController : EndSceneViewDelegate {
    func closeView(_ sender: EndSceneView) {
        level = 0
        lifeBar.reset()
        listensBar.reset()
    }
}

extension Notification.Name {
    static let passed = Notification.Name("passed")
    static let failed = Notification.Name("failed")
}

