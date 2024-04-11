//
//  GooseApp.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import SwiftUI

@main
struct GooseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About \(Bundle.main.appName)") { appDelegate.showAboutPanel() }
            }
            CommandGroup(after: .newItem) {
                Button("Logs") { Logger.openLog() }
                Button("Clear Logs") { Logger.clearLogs() }
                #if DEBUG
                    Button("Crash") {
                      fatalError("Crash was triggered")
                    }
                #endif
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
