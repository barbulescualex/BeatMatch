import UIKit
import AVFoundation
import SpriteKit

public class MidiButton : UIView, UIGestureRecognizerDelegate {
    private var player : AVAudioPlayer?
    
    private let sceneView = SKView()
    private let scene = SKScene()
    
//    private lazy var pulse : SKEmitterNode = {
//        let node = SKEmitterNode(fileNamed: "pulse.sks")
//        node?.particleColor = .yellow
//        return node!
//    }()
    

    public required init(frame: CGRect, sound: Sounds) {
        super.init(frame: frame)
        //initializing tap recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        setupPlayer(withSound: sound)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupView(){
        backgroundColor = .lightGray
        layer.cornerRadius = 10
        clipsToBounds = true
        isUserInteractionEnabled = true
        
//        sceneView.frame = frame
//        sceneView.backgroundColor = .clear
//        addSubview(sceneView)
//
//        scene.size = frame.size
//        scene.scaleMode = .aspectFit
//        scene.backgroundColor = .clear
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
//        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
//        pulseAnimation.duration = 30
//        pulseAnimation.fromValue = 0
//        pulseAnimation.toValue = 1
//        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        pulseAnimation.autoreverses = true
//        pulseAnimation.repeatCount = 0
//        layer.add(pulseAnimation, forKey: nil)
        
//        pulse.position = sceneView.center
//        scene.addChild(scene)
//        sceneView.presentScene(scene)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = .yellow
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = .lightGray
            })
        }
    }
    
    fileprivate func setupPlayer(withSound sound : Sounds){
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
