// The Swift Programming Language
// https://docs.swift.org/swift-book

import ObjectiveC
import Dispatch
import Foundation

public protocol LoggerProtocol: NSObjectProtocol {
    func format(log: Log) -> String
}

public class SailLogger {
    
    public static let shared = SailLogger()
    public weak var delegate: LoggerProtocol?
    public var level: Level = []
    public var output: Output = []
    public var maxLength = 1000 // 单条长度限制
    
    let queue = DispatchQueue(label: "com.hubery.hk.log")
    let timeFormatter = DateFormatter()
    
    init() {
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS z"
    }
    
    public static func log(msg: String, level: Level) {
        shared.log(msg: msg, level: level)
    }
    
    public func log(msg: String, level: Level,
                    file: String = #file, line: Int = #line) {
        guard !msg.isEmpty, self.level.contains(level) else { return }
        let log = Log(msg: msg, level: level, file: file, line: line)
        if let idx = log.msg.index(at: maxLength) {
            log.msg = String(log.msg[..<idx])
        }
        if let delegate {
            log.msg = delegate.format(log: log)
        } else {
            let timeStr = timeFormatter.string(from: log.date)
            log.msg = "[\(log.file):\(log.line)] \(timeStr)\n\(log.msg)"
        }
        if !log.msg.hasSuffix("\n") {
            log.msg.append("\n")
        }
        if output.contains(.console) {
            print(log.msg)
        } 
        if output.contains(.file) {
            queue.async {
                FileLogger.shared.log(log)
            }
        }
    }
    
}

extension String {
    
    func index(at i: Int) -> Index? {
        index(startIndex, offsetBy: i, limitedBy: endIndex)
    }
    
}
