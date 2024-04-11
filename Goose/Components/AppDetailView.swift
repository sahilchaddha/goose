//
//  AppDetail.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import SwiftUI
import Combine
import AudioToolbox

struct AppDetailView: View {
    @StateObject private var appService = AppService.shared
    @State private var enabled: Bool = false
    @State private var flash: Bool = false
    @State private var sound: Bool = false
    @State private var notification: Bool = false
    @State private var threshold: String = "1"
    @State private var showStatusBarItem: Bool = false
    var item: Item
    
    init(item: Item) {
        self.enabled = item.enabled
        self.flash = item.flash
        self.sound = item.sound
        self.notification = item.notification
        self.threshold = "\(item.threshold)"
        self.showStatusBarItem = item.showStatusItem
        self.item = item
    }
    
    private func updateValues() {
        item.enabled = enabled
        item.flash = flash
        item.sound = sound
        item.notification = notification
        item.threshold = Int32(Int(threshold) ?? 1)
        item.showStatusItem = showStatusBarItem
        appService.save()
    }
    
    @ViewBuilder func FlashToggle() -> some View {
        if #available(macOS 14, *) {
            Toggle("", isOn: $flash)
                .onChange(of: flash) { val in
                    if val {
                        AudioServicesPlayAlertSound(kSystemSoundID_FlashScreen)
                    }
                }
        } else {
            Toggle("", isOn: $flash)
        }
    }
    
    var body: some View {
        VStack {
            AppMetadataView(item: item)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Text("Enabled : ")
                Toggle("", isOn: $enabled)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Text("Flash screen: ")
                FlashToggle()
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Text("Play Sound : ")
                Toggle("", isOn: $sound)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Text("Trigger Notification : ")
                Toggle("", isOn: $notification)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Text("Show App in Menu Bar: ")
                Toggle("", isOn: $showStatusBarItem)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Text("Threshold : ")
                TextField("Threshold", text: $threshold)
                    .onReceive(Just(threshold)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.threshold = filtered
                        }
                    }
                .frame(width: 40)
                Text("notifications").font(.caption)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Button {
                    updateValues()
                } label: {
                    Text("Save")
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                Spacer()
            }
            
            Spacer()
        }
        .toolbar {
            // Save
            ToolbarItem {
                Button(action: {
                    if let bundleUrl = item.bundleUrl,
                       let bundle = bundleUrl.bundle() {
                        NSWorkspace.shared.open(bundle.bundleURL)
                    }
                }) {
                    Text("Open")
                        .padding()
                }
            }
            // Delete
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    appService.delete(item: item)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
