//
//  MonitorService.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import AppKit
import Combine
import AudioToolbox
import UserNotifications

public struct MonitorService {
    fileprivate static var checkInterval: TimeInterval = TimeInterval(Int(UserDefaults.checkInterval) ?? Int(10.0))
    
    public static let observerStatus = PassthroughSubject<Bool, Never>()
    public static var observedAppInfos: [String: ObservedAppInfo] = [:]
    private static var timer: Timer?
    private static var appCreateObserver: AXObserver!
    private static var appDestroyObserver: AXObserver!
    private static let onElementCreateCallback = ObserverCallbackInfo {
        reloadAppElements()
    }
    private static let onElementDestroyCallback = ObserverCallbackInfo {
        reloadAppElements()
//        observedAppInfos.keys.forEach { appName in
//            if let appElement = observedAppInfos[appName]?.appElement {
//                var title: AnyObject?
//                AXUIElementCopyAttributeValue(appElement, kAXTitleAttribute as CFString, &title)
//
//                // If we can't get the title from cachedTargetAppElement, then the app is terminated.
//                if title as? String == nil {
//                    observedAppInfos[appName]?.updateBadge(nil)
//                    observedAppInfos[appName]?.updateAppElement(nil)
//                }
//            }
//        }
    }
    
    public static func updateInterval(interval: Int) {
        checkInterval = TimeInterval(interval)
        setupObservers()
    }

    public static func setupObservers() {
        timer?.invalidate()
        Logger.log("MonitorService: Starting timer with \(checkInterval) interval")
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { timer in
            updateBadge()
        }
        updateBadge()
        timer?.fire()
    }
    
    private static func updateBadge() {
        if appCreateObserver == nil || appDestroyObserver == nil {
            setupAxObserversOnDock()
        }

        observedAppInfos.keys.forEach { appName in
            let newBadge = getBadgeText(appName: appName)
            observedAppInfos[appName]?.updateBadge(newBadge)
        }
        AppService.shared.updateBadges(notify: true)
    }

    public static func openMonitoredApp(appName: String) {
        if let cachedTargetAppElement = observedAppInfos[appName]?.appElement {
            AXUIElementPerformAction(cachedTargetAppElement, kAXPressAction as CFString)
        }
    }

    public static func isMonitoredAppRunning(bundleIdentifier: String) -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).isEmpty
    }

    public static func getBadgeText(appName: String) -> String? {
        guard let targetAppElement = observedAppInfos[appName]?.appElement else {
            return nil
        }

        var statusLabel: AnyObject?
        AXUIElementCopyAttributeValue(targetAppElement, "AXStatusLabel" as CFString, &statusLabel)
        return statusLabel as? String
    }

    private static func tryGetTargetAppElement(appName: String) -> AXUIElement? {
        guard let dockProcessId = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").last?.processIdentifier else {
            return nil
        }

        let dock = AXUIElementCreateApplication(dockProcessId)
        guard let dockChildren = getSubElements(root: dock) else {
            return nil
        }

        for child in dockChildren {
            var title: AnyObject?

            AXUIElementCopyAttributeValue(child, kAXTitleAttribute as CFString, &title)
            if let titleStr = title as? String,
               titleStr == appName {
                return child
            }
        }

        return nil
    }
    
    private static func getAllTargetAppElements() {
        guard let dockProcessId = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").last?.processIdentifier else {
            return
        }

        let dock = AXUIElementCreateApplication(dockProcessId)
        guard let dockChildren = getSubElements(root: dock) else {
            return
        }
        for child in dockChildren {
            var title: AnyObject?

            AXUIElementCopyAttributeValue(child, kAXTitleAttribute as CFString, &title)
            var statusLabel: AnyObject?
            AXUIElementCopyAttributeValue(child, "AXStatusLabel" as CFString, &statusLabel)
            if let title = title as? String {
                Logger.log("MonitorService: \(title) Badge Update : \(statusLabel as? String ?? "NaN")")
                observedAppInfos[title] = ObservedAppInfo(appElement: child, badge: statusLabel as? String)
            }
        }
        
        updateBadge()
    }

    private static func getSubElements(root: AXUIElement) -> [AXUIElement]? {
        var childrenCount: CFIndex = 0
        var err = AXUIElementGetAttributeValueCount(root, "AXChildren" as CFString, &childrenCount)
        var result: [AXUIElement] = []
        if case .success = err {
            var subElements: CFArray?;
            err = AXUIElementCopyAttributeValues(root, "AXChildren" as CFString, 0, childrenCount, &subElements)
            if case .success = err {
                if let children = subElements as? [AXUIElement] {
                    result.append(contentsOf: children)
                    children.forEach { element in
                        if let nestedChildren = getSubElements(root: element) {
                            result.append(contentsOf: nestedChildren)
                        }
                    }
                }

                return result
            }
        }

        Logger.log("MonitorService: Error \(err.rawValue)")
        return nil
    }

    private static func setupAxObserversOnDock() {
        Logger.log("MonitorService: Setup Observers on Dock")
        guard let dockProcessId = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").last?.processIdentifier else {
            Logger.log("MonitorService: NO DOCK")
            return
        }

        AXObserverCreateWithInfoCallback(dockProcessId, { (observer, element, notification, userData, refCon) in
            if let refCon = refCon {
                let callbackInfo = Unmanaged<ObserverCallbackInfo>.fromOpaque(refCon).takeUnretainedValue()
                callbackInfo.callback()
            }
        }, &appCreateObserver)

        AXObserverCreateWithInfoCallback(dockProcessId, { (observer, element, notification, userData, refCon) in
            if let refCon = refCon {
                let callbackInfo = Unmanaged<ObserverCallbackInfo>.fromOpaque(refCon).takeUnretainedValue()
                callbackInfo.callback()
            }
        }, &appDestroyObserver)

        if let observer = appCreateObserver {
            let callbackPTR = UnsafeMutableRawPointer(Unmanaged.passUnretained(onElementCreateCallback).toOpaque())
            let result = AXObserverAddNotification(observer, AXUIElementCreateApplication(dockProcessId), kAXCreatedNotification as CFString, callbackPTR)
            if result == .success {
                Logger.log("MonitorService: Successfully added element created Notification!")
            } else {
                Logger.log("MonitorService: Failed to add element notification \(result.rawValue)")
                getAllTargetAppElements()
                appCreateObserver = nil
            }

            CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), AXObserverGetRunLoopSource(observer), CFRunLoopMode.defaultMode)
        }

        if let observer = appDestroyObserver {
            let callbackPTR = UnsafeMutableRawPointer(Unmanaged.passUnretained(onElementDestroyCallback).toOpaque())

            if AXObserverAddNotification(observer, AXUIElementCreateApplication(dockProcessId), kAXUIElementDestroyedNotification as CFString, callbackPTR) == .success {
                Logger.log("MonitorService: Successfully added element destroyed Notification!")
            } else {
                appDestroyObserver = nil
            }

            CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), AXObserverGetRunLoopSource(observer), CFRunLoopMode.defaultMode)
        }
        Logger.log("MonitorService: Observer Status : \(appCreateObserver != nil)")
        observerStatus.send(appCreateObserver != nil)
        if appCreateObserver != nil && appDestroyObserver != nil {
            reloadAppElements()
        }
    }

    private static func reloadAppElements() {
        Logger.log("MonitorService: Reload Apps")
        getAllTargetAppElements()
    }
}

public struct ObservedAppInfo {
    var appElement: AXUIElement?
    var badge: String?

    mutating func updateAppElement(_ element: AXUIElement?) {
        appElement = element
    }
    
    mutating func updateBadge(_ appBadge: String?) {
        badge = appBadge
    }
}

private class ObserverCallbackInfo {
    var callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
}
