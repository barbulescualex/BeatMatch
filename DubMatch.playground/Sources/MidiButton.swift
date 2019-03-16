import UIKit
import AVFoundation
import SpriteKit

public class MidiButton : UIView, UIGestureRecognizerDelegate {
    private var player : AVAudioPlayer?
    private var sound : Sounds!

    public required init(sound: Sounds) {
        self.sound = sound
        super.init(frame: .zero)
        
        //initializing tap recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        
        setupPlayer()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupView(){
        backgroundColor = sound.color
        alpha = 0.2
        layer.cornerRadius = 10
        clipsToBounds = true
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        print("tapped")
        animatePressed()
        if let player = player, player.isPlaying {
            player.stop()
        }
        player?.play()
    }
    
    fileprivate func animatePressed(){
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.2
            })
        }
    }
    
    fileprivate func setupPlayer(){
        print(sound.rawValue, sound.fileExtension)
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: sound.fileExtension) else { return }
        print("found url")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
