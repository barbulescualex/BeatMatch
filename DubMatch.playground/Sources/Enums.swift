import Foundation

extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self {
        let a = Self.allCases
        return a[a.index(a.startIndex, offsetBy: index)]
    }
    
    func index() -> Int {
        let a = Self.allCases
        return a.distance(from: a.startIndex, to: a.firstIndex(of: self)!)
    }
}

public enum Sounds : String {
    case bass
    case snare
    case ghostSnare
    case hiHat
    case chime
    
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
        }
    }
}
