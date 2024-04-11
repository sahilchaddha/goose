//
//  BundleImage_Ext.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-21.
//

import Foundation
import AppKit

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var identifier: String { getInfo("CFBundleIdentifier")}
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}

extension String {
    func bundleImage() -> NSImage {
        if let bundleUrl = URL(string: self),
           let bundle = Bundle(url: bundleUrl) {
            return NSWorkspace.shared.icon(forFile: bundle.bundlePath)
        }
        return NSWorkspace.shared.icon(for: .application)
    }
    
    func bundle() -> Bundle? {
        if let bundleUrl = URL(string: self),
           let bundle = Bundle(url: bundleUrl) {
            return bundle
        }
        return nil
    }
}

extension URL {
    func bundleImage() -> NSImage {
        if let bundle = Bundle(url: self) {
            return NSWorkspace.shared.icon(forFile: bundle.bundlePath)
        }
        return NSWorkspace.shared.icon(for: .application)
    }
}
