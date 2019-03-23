import UIKit

public class LifeBar : UILabel {
    //MARK:- Vars
    public var lives = 5
    private var maxLives = 5
    
    //MARK:- Setup
    public required init(lives: Int) {
        self.lives = lives
        self.maxLives = lives
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 20)
        text = "❤"
        for _ in 0..<(maxLives-1) {
            text = text! + "❤"
        }
        textAlignment = .left
    }
    
    //MARK:- Functions
    public func minusOne(){
        text = ""
        lives = lives - 1
        for _ in 0..<lives {
            text = text! + "❤"
        }
    }
    
    public func reset(){
        lives = maxLives
        text = "❤"
        for _ in 0..<(maxLives-1) {
            text = text! + "❤"
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}


