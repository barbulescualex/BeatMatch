import UIKit

extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self {
        let a = Self.allCases
        return a[a.index(a.startIndex, offsetBy: index)]
    }
}

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
}
