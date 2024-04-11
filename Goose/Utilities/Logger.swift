//
//  Logger.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-30.
//

import Foundation
import AppKit

class Logger {
    
    fileprivate static func url() -> URL? {
        let fileManager = FileManager()
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        if let appDirectory = urls.first {
            return appDirectory.appendingPathComponent("goose.log", isDirectory: false)
        }
        return nil
    }
    
    public static func log(_ string: String) {
        guard let logUrl = url(),
              let stringData = string.appending("\n").data(using: .utf8) else { return }
        #if DEBUG
            print(string)
        #endif
        do {
            if FileManager.default.fileExists(atPath: logUrl.path) {
                let fileHandle = try FileHandle(forWritingTo: logUrl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(stringData)
                fileHandle.closeFile()
            } else {
                try stringData.write(to: logUrl)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public static func clearLogs() {
        guard let logUrl = url() else { return }
        
        if FileManager.default.fileExists(atPath: logUrl.path) {
            try? FileManager.default.removeItem(atPath: logUrl.path)
        }
    }
    
    public static func openLog() {
        guard let logUrl = url() else { return }
        let consoleURL = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app/")
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.open([logUrl], withApplicationAt: consoleURL, configuration: configuration)
    }
    
}
