//
//  File.swift
//  
//
//  Created by 李招雄 on 2023/12/28.
//

import Foundation

public class FileLogger {
    
    public static let shared = FileLogger()
    public var maxSize = 20 * 1024 * 1024
    var fileHandle: FileHandle?
    var fileName: String?
    
    init() {
        let url = logsUrl()
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
        }
    }
    
    func logsUrl() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var url = URL(fileURLWithPath: paths[0])
        let bid = Bundle.main.bundleIdentifier
        url.appendPathComponent(bid!+"/Logs")
        return url
    }
    
    func log(_ log: Log) {
        guard let data = log.msg.data(using: .utf8) else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: log.date)
        let name = String(format: "%d-%02d-%02d.log", components.year!, components.month!, components.day!)
        var url = logsUrl()
        url.appendPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        do {
            if fileName == nil {
                fileHandle = try FileHandle(forWritingTo: url)
                fileHandle?.seekToEndOfFile()
                fileHandle?.write(data)
                tryDeleteFile()
            } else if fileName == name {
                fileHandle?.write(data)
            } else {
                fileHandle?.closeFile()
                fileHandle = try FileHandle(forWritingTo: url)
                fileHandle?.write(data)
            }
            fileName = name
        } catch {
            print(error)
        }
    }
    
    func tryDeleteFile() {
        let logsUrl = logsUrl()
        do {
            var size = 0
            let names = try FileManager.default.contentsOfDirectory(atPath: logsUrl.path)
                .sorted(by: >)
            for name in names {
                let url = logsUrl.appendingPathComponent(name)
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                if let fs = attributes?[.size] as? Int {
                    size += fs
                }
                if size > maxSize {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        } catch {
            print(error)
        }
    }
    
}
