import UIKit
import AVFoundation
import Accelerate

protocol MidiCellDelegate : AnyObject {
    func pressed(_ cell: MidiCell)
}

public class MidiCell : UICollectionViewCell, UIGestureRecognizerDelegate {
    public var sound : Sounds?{
        didSet{
            light.backgroundColor = sound?.color
        }
    }
    public var engine : AVAudioEngine?{
        didSet{
            setupNode()
        }
    }
    
    private var firstPlay = true
    public var visualizer : Visualizer?
    
    private var player = AVAudioPlayerNode()
    private var audioFile = AVAudioFile()
    
    weak var delegate : MidiCellDelegate?
    
    public var cellIsPlaying = false
    
    private lazy var buttonArea : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private lazy var buttonCover : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var light : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        print("CELL INIT")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView(){
        backgroundColor = .clear
        
        //button area
        addSubview(buttonArea)
        buttonArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        buttonArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        buttonArea.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        buttonArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        buttonArea.addGestureRecognizer(tap)
        
        //light
        buttonArea.addSubview(light)
        light.centerXAnchor.constraint(equalTo: buttonArea.centerXAnchor).isActive = true
        light.centerYAnchor.constraint(equalTo: buttonArea.centerYAnchor).isActive = true
        light.widthAnchor.constraint(equalToConstant: 50).isActive = true
        light.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //light.isHidden = true
        
        //button cover
        buttonArea.addSubview(buttonCover)
        buttonCover.leadingAnchor.constraint(equalTo: buttonArea.leadingAnchor).isActive = true
        buttonCover.trailingAnchor.constraint(equalTo: buttonArea.trailingAnchor).isActive = true
        buttonCover.topAnchor.constraint(equalTo: buttonArea.topAnchor).isActive = true
        buttonCover.bottomAnchor.constraint(equalTo: buttonArea.bottomAnchor).isActive = true
    }
    
    fileprivate func setupNode(){
        let url = Bundle.main.url(forResource: sound!.rawValue, withExtension: sound!.fileExtension)!
        do {
            audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat
            //print(format)
            engine!.attach(player)
            engine!.connect(player, to: engine!.mainMixerNode, format: format)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if AVCoordinator.shared.isPlaying || cellIsPlaying { return }
        play()
        cellIsPlaying = true
        animate()
        delegate?.pressed(self)
    }
    
    public func play(){
        if(firstPlay){
            player.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, _) in
                AVCoordinator.shared.rms(from: buffer, with: 1024, cell: self)
            }
            firstPlay = false
        }
        player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        player.play()
    }
    
    public func animate(){
        UIView.animate(withDuration: 0.1, animations: {
            self.light.transform = CGAffineTransform(scaleX: 3, y: 3)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.light.transform = CGAffineTransform.identity
            })
        }
    }
    
    deinit {
        player.removeTap(onBus: 0)
    }
}
