//
//  PermissionService.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Cocoa
import Combine

final class PermissionService {
    private static var timer: Timer?
    public static var permissionStatus: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
    
    public static func startObservingPermissions() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            permissionStatus.send(isAccessibilityEnabled())
        }
        timer?.fire()
    }
    
    static func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let _ = AXIsProcessTrustedWithOptions(options)
    }
    
    static func isAccessibilityEnabled() -> Bool {
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(nil)
        return accessibilityEnabled
    }
}
