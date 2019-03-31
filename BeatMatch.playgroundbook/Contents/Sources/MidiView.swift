import UIKit
import AVFoundation

public class MidiView : UIView {
    //MARK:- Vars
    private var identifier = "cell"
    private var sounds = [Sounds.kick,Sounds.snare,Sounds.ghostSnare,Sounds.chime,Sounds.hiHat,Sounds.perc]
    private var engine : AVAudioEngine
    private var cellSwapped = (false,0,0) //Flag for our AVCoordinator to swap cell from index to index
    
    //MARK:- View Components
    public lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(MidiCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //MARK:- INIT
    public required init(engine: AVAudioEngine) {
        self.engine = engine
        super.init(frame: .zero)
        setupMidi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARL:- FUNCTIONS
    fileprivate func setupMidi(){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.cornerRadius = 20
        clipsToBounds = true
        isMultipleTouchEnabled = true
        isUserInteractionEnabled = true
        
        //collection view
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleMoveGesture(_:)))
        collectionView.addGestureRecognizer(longPress)
    }
}

//MARK:- COLLECTION VIEW
extension MidiView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //moving
    @objc func handleMoveGesture(_ sender : UILongPressGestureRecognizer){
        if AVCoordinator.shared.isPlaying {return}//no interaction with midi pad while sounds playing
        switch(sender.state) {
        case .began:
            guard let item = collectionView.indexPathForItem(at: sender.location(in: collectionView)) else {return}
            collectionView.beginInteractiveMovementForItem(at: item)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(sender.location(in: sender.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
        
    }
    
    //population
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell init called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MidiCell
        cell.sound = sounds[indexPath.item]
        cell.engine = engine
        cell.delegate = AVCoordinator.shared
        if !cellSwapped.0 {
            AVCoordinator.shared.cells.append(cell)
            AVCoordinator.shared.cellAccurateIndexes.append(indexPath.item)
        } else {
            let swapFrom = cellSwapped.1
            let swapTo = cellSwapped.2
            AVCoordinator.shared.cells.remove(at: swapFrom)
            let indexReferenceToMove = AVCoordinator.shared.cellAccurateIndexes[swapFrom]
            AVCoordinator.shared.cellAccurateIndexes.remove(at: swapFrom)
            AVCoordinator.shared.cells.insert(cell, at: swapTo)
            AVCoordinator.shared.cellAccurateIndexes.insert(indexReferenceToMove, at: swapTo)
            cellSwapped = (false,0,0)
        }
        return cell
    }
    
    //selection
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //sizing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3 - 9
        let height = collectionView.bounds.height / 2 - 6
        return CGSize(width: width, height: height)
    }
    
    //moving
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let soundToMove = sounds[sourceIndexPath.item]
        sounds.remove(at: sourceIndexPath.item)
        sounds.insert(soundToMove, at: destinationIndexPath.item)
        cellSwapped = (true, sourceIndexPath.item, destinationIndexPath.item)
    }
}
