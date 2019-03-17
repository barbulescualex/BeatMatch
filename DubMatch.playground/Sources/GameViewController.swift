import UIKit


public class GameViewController : UIViewController {
    
    lazy var levelLabel : UILabel = {
        let label = UILabel()
        label.text = "Level:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var resetButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "restart")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(restart(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    var midiView : MidiView?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        setupViews()
    }
    
    fileprivate func setupViews(){
        view.backgroundColor = .white
        
        //topstack
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        topStack.addArrangedSubview(levelLabel)
        topStack.addArrangedSubview(resetButton)
        
        view.addSubview(topStack)
        topStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 3).isActive = true
        topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3).isActive = true
        topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -3).isActive = true
        topStack.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        print(view.bounds)
        
        //midiview
        midiView = MidiView()
        view.addSubview(midiView!)
        midiView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        midiView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        midiView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let midiHeight = view.bounds.height*0.25
        midiView?.heightAnchor.constraint(equalToConstant: midiHeight).isActive = true
        
    }
    
    @objc func restart(_ sender: UIButton){
        
    }
}

