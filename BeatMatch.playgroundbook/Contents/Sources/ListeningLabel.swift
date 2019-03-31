import UIKit

public class ListneningLabel : UILabel {
    //MARK:- VARS
    private var timer : Timer?
    private var dots = 0
    
    public override var isHidden: Bool{
        get{
            return super.isHidden
        }
        set{
            print("listening isHidden set to: ", newValue)
            super.isHidden = newValue
            print("listening super.isHidden is: ", super.isHidden)
            if super.isHidden {
                timer?.invalidate()
            } else {
                setupTimerForDots()
            }
        }
    }
    
    //MARK:- INIT
    public required init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARK:- FUNCTIONS
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 20)
        text = "Listening"
        textColor = .white
        textAlignment = .left
    }
    
    fileprivate func setupTimerForDots(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 0.2)!, repeats: true, block: { [weak self](t) in
            guard let dots = self?.dots else {return}
            if self?.text == nil {return}
            if dots == 3 {
                self!.text = "Listening"
                self!.dots = 0
            } else {
                self!.text!.append(Character("."))
                self!.dots = self!.dots + 1
            }
        })
    }
    
}
