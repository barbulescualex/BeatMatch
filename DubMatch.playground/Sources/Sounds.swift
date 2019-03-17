import UIKit

extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self {
        let a = Self.allCases
        return a[a.index(a.startIndex, offsetBy: index)]
    }
}

public enum Sounds : String, CaseIterable {
    case bass
    case snare
    case ghostSnare
    case hiHat
    case chime
    case voice
    
    public enum ext : String {
        case mp3
        case aiff
        case aif
        case wav
    }
    
    var fileExtension: String {
        switch self {
        case .bass:
            return ext.aiff.rawValue
        case .snare, .chime:
            return ext.mp3.rawValue
        case .hiHat:
            return ext.aif.rawValue
        case .ghostSnare:
            return ext.wav.rawValue
        case .voice:
            return ext.wav.rawValue
        }
    }
    
    var color: UIColor {
        switch self {
        case .bass:
            return UIColor.blue
        case .snare:
            return UIColor.purple
        case .chime:
            return UIColor.green
        case .hiHat:
            return UIColor.orange
        case .ghostSnare:
            return UIColor.yellow
        case .voice:
            return UIColor.red
        }
    }
}