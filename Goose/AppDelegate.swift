//
//  AppDelegate.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import Cocoa
import AppKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, UNUserNotificationCenterDelegate {
    private var statusItem: NSStatusItem!
    private var aboutPanelController: NSWindowController?
    var _forceQuit: Bool = false
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.delegate = self
        NSApp.windows.first?.delegate = self
        UNUserNotificationCenter.current().delegate = self
        PermissionService.startObservingPermissions()
        MonitorService.setupObservers()
        statusItem = StatusItemService.shared.createStatusItem()
        requestNotificationPermission()
        Logger.log("App: Start")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        Logger.log("App: Turning to accessory mode")
        NSApplication.shared.setActivationPolicy(.accessory)
        return false
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApp.hide(self)
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if NSApplication.shared.activationPolicy() == .accessory || _forceQuit {
            _forceQuit = false
            Logger.log("App: Force Quitting")
            return .terminateNow
        }
        Logger.log("App: Turning to accessory mode")
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.hide(self)
        return .terminateCancel
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                Logger.log("App: Notifications enabled")
            } else if let error {
                Logger.log("App: \(error.localizedDescription)")
            }
        }
    }
    
    func forceQuit() {
        Logger.log("App: Force Quitting")
        _forceQuit = true
        NSApp.terminate(self)
    }
    
    func showGoose() {
        Logger.log("App: Bringing app to foreground")
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApplication.shared.unhide(self)
        
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            window.setIsVisible(true)
        }
    }
    
    func showAboutPanel() {
        if aboutPanelController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable, .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = "About \(Bundle.main.appName)"
            window.contentView = NSHostingView(rootView: AboutView())
            window.center()
            aboutPanelController = NSWindowController(window: window)
        }
        
        aboutPanelController?.showWindow(aboutPanelController?.window)
    }
}
