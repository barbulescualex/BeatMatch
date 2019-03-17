import UIKit

public protocol MidiFlowLayoutDelegate : AnyObject {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize 
}

public class MidiFlowLayout : UICollectionViewFlowLayout {
    let innerSpace: CGFloat = 1.0
    let numberOfCellsOnRow: CGFloat = 3
    
    public override init() {
        super.init()
        self.minimumLineSpacing = innerSpace
        self.minimumInteritemSpacing = innerSpace
        self.scrollDirection = .vertical
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    func itemWidth() -> CGFloat {
//        return (collectionView!.frame.size.width/self.numberOfCellsOnRow)-self.innerSpace
//    }
    
//    override var itemSize: CGSize {
//        set {
//            self.itemSize = CGSize(width:itemWidth(), height:itemWidth())
//        }
//        get {
//            return CGSize(width:itemWidth(),height:itemWidth())
//        }
//    }
}

extension MidiFlowLayout : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size delegate called")
        let side = (collectionView.frame.size.width/self.numberOfCellsOnRow)-self.innerSpace
        return CGSize(width: side, height: side)
    }
}

