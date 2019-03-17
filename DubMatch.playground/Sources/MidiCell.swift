import UIKit
import AVFoundation

public class MidiCell : UICollectionViewCell, UIGestureRecognizerDelegate {
    public var sound : Sounds? {
        didSet{
            url = Bundle.main.url(forResource: sound!.rawValue, withExtension: sound!.fileExtension)
        }
    }
    private var url : URL?
    private var players = [AVAudioPlayer]()
    
    private lazy var buttonArea : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .lightGray
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        print("midi cell init called")
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView(){
        backgroundColor = .clear
        
        addSubview(buttonArea)
        
        buttonArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        buttonArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        buttonArea.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        buttonArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        buttonArea.addGestureRecognizer(tap)
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        animate()
        playSound()
    }
    
    public func animate(){
        UIView.animate(withDuration: 0.1, animations: {
           self.buttonArea.backgroundColor = self.sound?.color
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.buttonArea.backgroundColor = .lightGray
            })
        }
    }
    
    public func playSound(){
        if (sound == Sounds.voice) {
//            let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "WWDC 2019")
//            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//
//            //speechUtterance.rate = 1
//            
//            let speechSynthesizer = AVSpeechSynthesizer()
//            speechSynthesizer.speak(speechUtterance)
            return
        }
        guard let url = url else {return}
        print("url exists")
        do {
            //            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            //            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            players.append(player)
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension MidiCell : AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let index = players.firstIndex(of: player)!
        players.remove(at: index)
    }
}
