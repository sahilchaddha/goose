//
//  AppService.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import SwiftUI
import Combine
import AudioToolbox
import UserNotifications

struct RunningApp: Identifiable, Hashable, Equatable {
    var id: String {
        return "\(hashValue)"
    }
    var bundleId: String
    let name: String
    let url: URL?
    let executableUrl: URL?
    
    static func == (lhs: RunningApp, rhs: RunningApp) -> Bool {
        return lhs.bundleId == rhs.bundleId
    }
}

final class AppService: ObservableObject {
    static var shared = AppService()
    
    @Published var runningApps: [RunningApp] = [RunningApp]()
    @Published var monitoredApps: [Item] = [Item]()
    @Published var statusIcons: [StatusItemInfo] = []
    fileprivate var lastNotificationTrigger: [String: Date] = [: ]
    
    func fetchRunningApplications() {
        var apps: [String: RunningApp] = [: ]
        NSWorkspace.shared.runningApplications.forEach { (app: NSRunningApplication) in
            guard let name = app.localizedName,
                  let bundleIdentifier = app.bundleIdentifier else { return }
            let macApp = RunningApp(bundleId: bundleIdentifier, name: name, url: app.bundleURL, executableUrl: app.executableURL)
            apps[bundleIdentifier] = macApp
        }
        runningApps = Array(apps.values).sorted(by: { app1, app2 in
            return app1.name.lowercased() < app2.name.lowercased()
        })
    }
    
    func fetchMonitoredApplications() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
        let results = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        monitoredApps = results ?? []
        updateBadges()
    }
    
    func addItem(app: RunningApp) {
        if (monitoredApps.compactMap({$0.bundleId}).contains(app.bundleId)) {
            return
        }
        withAnimation {
            let newItem = Item(context: PersistenceController.shared.container.viewContext)
            newItem.timestamp = Date()
            newItem.name = app.name
            newItem.bundleId = app.bundleId
            newItem.bundleUrl = app.url?.absoluteString
            newItem.enabled = true
            newItem.flash = false
            newItem.threshold = 1
            newItem.showStatusItem = true
            newItem.sound = false
            newItem.notification = false
            newItem.executableUrl = app.executableUrl?.absoluteString
            save()
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { monitoredApps[$0] }.forEach(PersistenceController.shared.container.viewContext.delete)
            save()
        }
    }
    
    func delete(item: Item) {
        PersistenceController.shared.container.viewContext.delete(item)
        save()
    }
    
    func save() {
        do {
            try PersistenceController.shared.container.viewContext.save()
            fetchMonitoredApplications()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    fileprivate func shouldNotify(_ bundleId: String) -> Bool {
        guard let lastTriggerDate = lastNotificationTrigger[bundleId],
              let notificationInterval = Int(UserDefaults.notificationInterval) else {
            lastNotificationTrigger[bundleId] = Date.now
            Logger.log("AppService: Notifying since no last notificationInterval found")
            return true
        }
        
        let diffSeconds = Int(Date.now.timeIntervalSince1970 - lastTriggerDate.timeIntervalSince1970)
        if (diffSeconds / 60) >= notificationInterval {
            lastNotificationTrigger[bundleId] = Date.now
            Logger.log("AppService: Notifying since \(diffSeconds / 60) > \(notificationInterval)")
            return true
        }
        Logger.log("AppService: Not Notifying since \(diffSeconds / 60) < \(notificationInterval)")
        return false
    }
    
    func updateBadges(notify: Bool = false) {
        guard monitoredApps.count > 0 else {
            return
        }
        var pendingNotifications: [String: String] = [: ]
        monitoredApps.forEach { app in
            if let name = app.name,
               app.enabled,
               let appInfo = MonitorService.observedAppInfos[name],
               let bundleId = app.bundleId,
               let badgeCount = appInfo.badge {
                var shouldTriggerNotification = false
                if let badgeCountNumber = Int(badgeCount),
                   badgeCountNumber >= app.threshold {
                    shouldTriggerNotification = notify ? shouldNotify(bundleId): false
                } else {
                    shouldTriggerNotification = false
                }
                Logger.log("Should notify \(app.name) : \(shouldTriggerNotification)")
                // Flash Screen
                if app.flash && notify && shouldTriggerNotification {
                    AudioServicesPlayAlertSound(kSystemSoundID_FlashScreen)
                }
                
                if app.showStatusItem,
                   let bundleUrl = app.bundleUrl {
                    // Add to Status Item
                    pendingNotifications[bundleUrl] = badgeCount
                }
                
                if app.notification && notify && shouldTriggerNotification {
                    // Trigger Notification
                    let content = UNMutableNotificationContent()
                    content.title = "\(name) alert !"
                    content.subtitle = "Unread \(badgeCount) notifications"
                    content.sound = UNNotificationSound.default
                    content.interruptionLevel = .timeSensitive
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                }
                
                if app.sound && notify && shouldTriggerNotification {
                    // Play Sound
                    if let resource = Bundle.main.path(forResource: "honk", ofType: "mp3") {
                        let honk = URL(fileURLWithPath: resource)
                        AudioPlayerService.shared.play(url: honk)
                    }
                }
                
                if UserDefaults.httpRequest && notify && shouldTriggerNotification {
                    guard let requestEndpoint = UserDefaults.requestEndpoint,
                          let requestUrl = URL(string: requestEndpoint) else {
                        return
                    }
                    let requestType = UserDefaults.requestType
                    let requestBody = UserDefaults.requestBody
                    var request = URLRequest(url: requestUrl)
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    request.setValue("application/json", forHTTPHeaderField: "Content-type")
                    request.httpMethod = requestType
                    let notificationText = "\(name) notifications : \(badgeCount)"
                    let body = requestBody.replacingOccurrences(of: "$ALERT", with: notificationText)
                    let jsonData = body.data(using: .utf8)
                
                    request.httpBody = jsonData
                    let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
                        guard let data = data else { return }
                        let _ = String(data: data, encoding: .utf8)
                    }
                
                    task.resume()
                }
            } else {
                Logger.log("Couldnt find app badge for \(app.name), \(MonitorService.observedAppInfos[app.name ?? ""]) : \(app.bundleId)")
            }
        }
        
        var statusItems: [StatusItemInfo] = []
        pendingNotifications.forEach({ key, value in
            statusItems.append(StatusItemInfo(url: key, badge: value))
        })
        statusItems = statusItems.sorted(by: { a, b in
            let aBadge = Int(a.badge) ?? 0
            let bBadge = Int(b.badge) ?? 0
            
            return aBadge > bBadge
        })
        if !UserDefaults.hideIconIfEmpty {
            let appsThatWantToBeOnStatusBar = monitoredApps.filter { item in
                if let bundleUrl = item.bundleUrl {
                    return item.showStatusItem && pendingNotifications[bundleUrl] == nil
                }
                return false
            }
            if statusItems.count < 5 {
                statusItems.append(contentsOf: appsThatWantToBeOnStatusBar.compactMap({ item in
                    if let bundleUrl = item.bundleUrl {
                        return StatusItemInfo(url: bundleUrl, badge: "")
                    }
                    return nil
                }))
            }
        }
        if statusItems.count > 0 {
            statusItems = Array(statusItems.prefix(5))
        }
        statusIcons = statusItems
    }
    
}
