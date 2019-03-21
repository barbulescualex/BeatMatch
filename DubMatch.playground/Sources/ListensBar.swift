import UIKit

protocol ListensBarDelegate : AnyObject {
    func listensBarTapped()
}

public class ListensBar : UIStackView, UIGestureRecognizerDelegate {
    private var speakers = 3
    private var labels = [UILabel]()
    
    weak var delegate : ListensBarDelegate?
    
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
            addArrangedSubview(label)
            labels.append(label)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    public func minusOne(){
        UIView.animate(withDuration: 0.2) {
            self.labels[self.speakers-1].isHidden = true
        }
        speakers = speakers - 1
    }
    
    public func reset(){
        UIView.animate(withDuration: 0.2) {
            self.labels[0].isHidden = false
            self.labels[1].isHidden = false
            self.labels[2].isHidden = false
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
        speakers = 3
    }
    
    @objc func tapped(_ sender: UIGestureRecognizer){
        if speakers != 0 {
              delegate?.listensBarTapped()
        }
    }
}

