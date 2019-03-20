import UIKit


public class ListensBar : UILabel {
    private var speakers = 3
    
    public required init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 20)
        text = "🔉🔉🔉"
        textAlignment = .left
    }
    
    public func minusOne(){
        text = ""
        speakers = speakers - 1
        for _ in 0..<speakers {
            text = text! + "🔉"
        }
    }
    
    public func reset(){
        speakers = 3
        text = "🔉🔉🔉"
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}

