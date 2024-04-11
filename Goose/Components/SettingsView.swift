//
//  SettingsView.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-14.
//

import Foundation
import SwiftUI
import LaunchAtLogin
import Combine
import CodeViewer

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            APISettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "ellipsis.curlybraces")
                }
        }
        .frame(width: 600, height: 400)
    }
}

struct GeneralSettingsView: View {
    @Environment(\.controlActiveState) private var controlActiveState
    @AppStorage("goose.hideIconIfEmpty") private var hideIconIfEmpty: Bool = false
    @AppStorage("goose.interval") private var interval: String = "10"
    @AppStorage("goose.notificationInterval") private var notificationInterval: String = "3"
    @AppStorage("goose.httpRequest") private var callApi: Bool = false
    @AppStorage("goose.statusIconSize") private var statusIconSize = "Small"
    let statusIconSizes = ["Small", "Medium", "Large"]
    @ViewBuilder
    func statusIconPickerContent() -> some View {
        ForEach(statusIconSizes, id: \.self) {
            Text($0)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                LaunchAtLogin.Toggle {
                    Text("Launch at login")
                }
                Spacer()
            }
            HStack {
                Toggle(isOn: $hideIconIfEmpty, label: {
                    Text("Hide icon if theres no new notifications")
                })
                Spacer()
            }
            HStack {
                Text("Dock Monitor Interval : ")
                TextField("Interval", text: $interval)
                    .onReceive(Just(interval)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.interval = filtered
                        }
                    }
                .frame(width: 40)
                Text("seconds").font(.caption)
                Spacer()
            }
            .padding(.vertical)
            HStack {
                Text("Notification Interval : ")
                TextField("Notification Interval", text: $notificationInterval)
                    .onReceive(Just(notificationInterval)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.notificationInterval = filtered
                        }
                    }
                .frame(width: 40)
                Text("minutes").font(.caption)
                Spacer()
            }
            
            // HTTP Method
            HStack {
                Picker("Status Icon Size :", selection: $statusIconSize) {
                    statusIconPickerContent()
                }
                .pickerStyle(DefaultPickerStyle())
                .frame(width: 200)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .onChange(of: controlActiveState) { newValue in
                 switch newValue {
                 case .key, .active:
                     break
                 case .inactive:
                     if let intervalSeconds = Int(interval) {
                         MonitorService.updateInterval(interval: intervalSeconds)
                     }
                     break
                 @unknown default:
                     break
                 }
             }
    }
}

#Preview {
    SettingsView()
}
