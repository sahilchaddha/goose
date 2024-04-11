//
//  StatusItemService.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-17.
//

import Foundation
import SwiftUI
import Combine

final class StatusItemService: ObservableObject {
    static var shared = StatusItemService()
    private var hostingView: NSHostingView<StatusItem>?
    private var statusItem: NSStatusItem?
    
    private var sizePassthrough = PassthroughSubject<CGSize, Never>()
    private var sizeCancellable: AnyCancellable?
    
    func createStatusItem() -> NSStatusItem {
        let statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let hostingView = NSHostingView(rootView: StatusItem(sizePassthrough: sizePassthrough))
        hostingView.frame = NSRect(x: 0, y: 0, width: 80, height: 24)
        statusItem.button?.frame = hostingView.frame
        statusItem.button?.addSubview(hostingView)
        let menu = NSMenu()
        
        let openGoose = NSMenuItem(title: "Open Goose", action: #selector(openGoose), keyEquivalent: "n")
        openGoose.target = self
        menu.addItem(openGoose)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitApp = NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q")
        quitApp.target = self
        menu.addItem(quitApp)
        statusItem.menu = menu
        
        self.statusItem = statusItem
        self.hostingView = hostingView
        
        sizeCancellable = sizePassthrough.sink { [weak self] size in
            let frame = NSRect(origin: .zero, size: .init(width: size.width, height: 24))
            self?.hostingView?.frame = frame
            self?.statusItem?.button?.frame = frame
        }
        return statusItem
    }
    
    @objc func openGoose() {
        (NSApplication.shared.delegate as? AppDelegate)?.showGoose()
    }
    
    @objc func quitApplication() {
        (NSApplication.shared.delegate as? AppDelegate)?.forceQuit()
    }
}
