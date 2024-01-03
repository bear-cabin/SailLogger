//
//  File.swift
//  
//
//  Created by 李招雄 on 2023/12/28.
//

import UIKit
import Combine

@available(iOS 13.0, *)
public class FileLogger {
    
    public static let shared = FileLogger()
    public var maxSize = 20 * 1024 * 1024
    
    public let fileContentSubject = CurrentValueSubject<String, Never>("")
    public let fileNamesSubject = PassthroughSubject<(), Never>()

    var fileHandle: FileHandle?
    var fileName: String?
    
    public var logsUrl: URL = {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var url = URL(fileURLWithPath: paths[0])
        let bid = Bundle.main.bundleIdentifier
        url.appendPathComponent(bid!+"/Logs")
        return url
    }()
    
    init() {
        if !FileManager.default.fileExists(atPath: logsUrl.path) {
            try? FileManager.default.createDirectory(atPath: logsUrl.path, withIntermediateDirectories: true)
        }
    }
    
    func log(_ log: Log) {
        guard let data = log.msg.data(using: .utf8) else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: log.date)
        let name = String(format: "%d-%02d-%02d.log", components.year!, components.month!, components.day!)
        var url = logsUrl
        url.appendPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
            DispatchQueue.main.async {
                self.fileNamesSubject.send()
            }
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
            DispatchQueue.main.async {
                self.fileContentSubject.send(name)
            }
        } catch {
            print(error)
        }
    }
    
    func tryDeleteFile() {
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
            if size > maxSize {
                DispatchQueue.main.async {
                    self.fileNamesSubject.send()
                }
            }
        } catch {
            print(error)
        }
    }
    
}
