//
//  Sandbox.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-30.
//

import Foundation
import AppKit

struct Sandbox {
    static func isSandboxingEnabled() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["APP_SANDBOX_CONTAINER_ID"] != nil
    }
}
