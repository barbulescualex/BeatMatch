import UIKit

protocol ListensBarDelegate : AnyObject {
    func listensBarTapped()
}

public class ListensBar : UIStackView, UIGestureRecognizerDelegate {
    //MARK:- Vars
    private var listens = 3
    private var maxListens = 3
    private var labels = [UILabel]()
    
    private var speakers = ["🔈","🔉","🔊"]
    private var speakerIndex = 0
    public var timer : Timer?
    
    weak var delegate : ListensBarDelegate?
    
    //MARK:- Setup
    public required init(listens: Int) {
        self.listens = listens
        self.maxListens = listens
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
        for _ in 0..<maxListens {
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
    
    //MARK:- Functions
    public func minusOne(){
        UIView.animate(withDuration: 0.2) {
            self.labels[self.listens-1].isHidden = true
        }
        listens = listens - 1
        timer?.invalidate()
    }
    
    public func reset(){
        for label in labels {
            UIView.animate(withDuration: 0.2) {
                label.isHidden = false
            }
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
        listens = maxListens
    }
    
    @objc func tapped(_ sender: UIGestureRecognizer){
        if listens != 0 && !AVCoordinator.shared.isPlaying{
              delegate?.listensBarTapped()
            setupTimerForSpeakers()
        }
    }
    
    fileprivate func setupTimerForSpeakers(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 0.2)!, repeats: true, block: { [weak self](t) in
            if self == nil {
                return
            }
            if self!.speakerIndex == 2 {
                self!.speakerIndex = 0
            }
            self!.labels[self!.listens-1].text = self!.speakers[self!.speakerIndex]
            self!.speakerIndex = self!.speakerIndex + 1
        })
    }
}

