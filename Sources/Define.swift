//
//  File.swift
//  
//
//  Created by 李招雄 on 2023/12/28.
//

import Foundation

public struct Level: OptionSet, Hashable, Identifiable {
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public var id: Int { rawValue }
    public var name: String {
        switch self {
        case .error: return "ERROR"
        case .warn: return "WARN"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        default: return "ALL"
        }
    }
    public static var allCases: [Level] {
        [.error, .warn, .info, .debug]
    }
    public static let error = Level(rawValue: 1 << 0)
    public static let warn = Level(rawValue: 1 << 1)
    public static let info = Level(rawValue: 1 << 2)
    public static let debug = Level(rawValue: 1 << 3)
    public static let all = Level(rawValue: Int.max)
}

public struct Output: OptionSet {
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let console = Output(rawValue: 1 << 0)
    public static let file = Output(rawValue: 1 << 1)
}

public class Log {
    public var msg: String
    public let level: Level
    public let file: String
    public let line: Int
    public let date = Date()
    
    init(msg: String, level: Level,
         file: String, line: Int) {
        self.msg = msg
        self.level = level
        self.file = NSString(string: file).lastPathComponent
        self.line = line
    }
}
