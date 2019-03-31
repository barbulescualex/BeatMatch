import UIKit

public class LifeBar : UIStackView {
    //MARK:- VARS
    public var lives = 5
    private var maxLives = 5
    private var labels = [UILabel]()
    
    //MARK:- INIT
    public required init(lives: Int) {
        self.lives = lives
        self.maxLives = lives
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARK:- Functions
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fill
        for _ in 0..<maxLives {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20)
            label.text = "❤"
            addArrangedSubview(label)
            labels.append(label)
        }
    }
    
    public func minusOne(){
        let label = labels[lives-1]
        UIView.animate(withDuration: 0.1, animations: {
            label.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                label.transform = CGAffineTransform(scaleX: 0, y: 0)
            }, completion: { (_) in
                label.isHidden = true
                label.transform = CGAffineTransform.identity
            })
        }
        lives = lives - 1
    }
    
    public func reset(){
        for label in labels {
            if label.isHidden == false {
                continue
            }
            label.isHidden = false
            label.text = "❤"
            UIView.animate(withDuration: 0.1, animations: {
                label.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (_) in
                UIView.animate(withDuration: 0.1, animations: {
                    label.transform = CGAffineTransform.identity
                })
            }
        }
        lives = maxLives
    }
}


