import UIKit

public class LifeBar : UILabel {
    private var hearts = 5
    
    public required init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 30)
        text = "❤❤❤❤❤"
        textAlignment = .left
    }
    
    public func minusOne(){
        text = ""
        hearts = hearts - 1
        for _ in 0..<hearts {
            text = text! + "❤"
        }
    }
    
    public func reset(){
        hearts = 5
        text = "❤❤❤❤❤"
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}


