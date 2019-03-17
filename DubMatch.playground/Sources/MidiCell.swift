import UIKit
import AVFoundation

public class MidiCell : UICollectionViewCell {
    public var sound : Sounds? {
        didSet{
            url = Bundle.main.url(forResource: sound!.rawValue, withExtension: sound!.fileExtension)
            buttonArea.backgroundColor = sound!.color
        }
    }
    private var url : URL?
    private var players = [AVAudioPlayer]()
    
    private lazy var buttonArea : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
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
        buttonArea.alpha = 0.2
        
        buttonArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        buttonArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        buttonArea.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        buttonArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    public func animate(){
        UIView.animate(withDuration: 0.1, animations: {
           self.buttonArea.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.buttonArea.alpha = 0.2
            })
        }
    }
    
    public func playSound(){
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
