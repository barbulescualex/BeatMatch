import UIKit


public class ListensBar : UIStackView {
    private var speakers = 3
    private var labels = [UILabel]()
    
    public required init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fill
        for _ in 0..<3 {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20)
            label.text = "🔉"
            addSubview(label)
            labels.append(label)
        }
    }
    
    public func minusOne(){
        UIView.animate(withDuration: 0.2) {
            self.labels[self.speakers-1].isHidden = true
        }
    }
    
    public func reset(){
        UIView.animate(withDuration: 0.2) {
            self.labels[0].isHidden = false
            self.labels[1].isHidden = false
            self.labels[2].isHidden = false
        }
    }
}

