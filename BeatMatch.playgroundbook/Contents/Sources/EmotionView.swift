import UIKit
import AVFoundation


public class EmotionView : UIView {
    //MARK:- VARS
    private var message : EmotionMessage!
    private var player : AVAudioPlayer?
    
    //MARK:- INIT
    public required init(message : EmotionMessage) {
        self.message = message
        super.init(frame: .zero)
        playSound()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARK:- FUNCTIONS
    fileprivate func playSound(){
        guard let url = Bundle.main.url(forResource: message.sound, withExtension: message.fileExtension) else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print(error)
        }
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
