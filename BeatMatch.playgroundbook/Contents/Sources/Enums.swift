import UIKit

extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self {
        let a = Self.allCases
        return a[a.index(a.startIndex, offsetBy: index)]
    }
}

//MARK:- EMOTIONS
public enum EmotionMessage : String, CaseIterable {
    case NICE
    case AWESOME
    case SWEET
    case DOPE
    
    case AWE
    
    var emoji : String {
        switch self {
        case .NICE:
            return "👍"
        case .AWESOME:
            return "💪"
        case .SWEET:
            return "😎"
        case .DOPE:
            return "😈"
        case .AWE:
            return "😢"
        }
    }
    
    var sound : String {
        switch self {
        case .NICE:
            return "nice"
        case .AWESOME:
            return "awesome"
        case .SWEET:
            return "sweet"
        case .DOPE:
            return "dope"
        case .AWE:
            return "awe"
        }
    }
    
    var fileExtension: String {
        return "mp3"
    }
}

//MARK:- END STATE
public enum EndMessage {
    case over
    case win
    
    var title : String {
        switch self {
        case .win:
            return "YOU WON!"
        case .over:
            return "GAME OVER"
        }
    }
    
    var prefixEmoji : String {
        switch self {
        case .win:
            return "🤙"
        case .over:
            return "😫"
        }
    }
    
    var suffixEmoji : String {
        switch self {
        case .win:
            return "🎉"
        case .over:
            return "😢"
        }
    }
    
    var sound : String {
        switch self {
        case .win:
            return "win"
        case .over:
            return "over"
        }
    }
    
    var fileExtension : String {
        return "mp3"
    }
}

//MARK:- SOUNDS
public enum Sounds : String, CaseIterable {
    case kick
    case snare
    case ghostSnare
    case hiHat
    case chime
    case perc
    
    var fileExtension: String {
        return "mp3"
    }
    
    var color: UIColor {
        switch self {
        case .kick:
            return UIColor.blue
        case .snare:
            return UIColor.purple
        case .chime:
            return UIColor.green
        case .hiHat:
            return UIColor.orange
        case .ghostSnare:
            return UIColor.yellow
        case .perc:
            return UIColor.red
        }
    }
    
    var msTime: Int {
        switch self {
        case .kick:
            return 200
        case .snare:
            return 21
        case .chime:
            return 90
        case .hiHat:
            return 170
        case .ghostSnare:
            return 200
        case .perc:
            return 170
        }
    }
}

//MARK:- DIFFICULTY
public enum Difficulty {
    case baby
    case easy
    case normal
    case hard
    
    public var pattern : [String] {
        switch self {
        case .baby:
            return ["000","111","112","1122","1122101"]
        case .easy:
            return ["001 001", "022112", "001 001 0010001", "0324111", "03030322 03030311"]
        case .normal:
            return ["0034 003", "5555 0303 333", "032303230323 001", "1 2 11231120", "150003 3434001"]
        case .hard:
            return ["03212", "0425333 0425111", "00131313 55 555 10", "0021001 0055442231343210", "3243240 23042304 03240324"]
        }
    }
}
