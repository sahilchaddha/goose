//
//  FloatingPanel.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import SwiftUI

struct FloatingPanelView: View {
    @Binding var showingPanel: Bool
    @StateObject var appService: AppService = AppService.shared
    var addItem: ((RunningApp) -> Void )?
    
    var body: some View {
        ScrollView {
            HStack {
                Image(nsImage: NSWorkspace.shared.icon(for: .application))
                VStack {
                    HStack {
                        Text("Manually select app from finder")
                        Spacer()
                    }
                }
            }
            .padding(.vertical)
            .contentShape(Rectangle())
            .onTapGesture {
                showingPanel.toggle()
                pickApplication()
            }
            
            ForEach(appService.runningApps) { app in
                HStack {
                    if let bundleUrl = app.url {
                        Image(nsImage: bundleUrl.bundleImage())
                    }
                    VStack {
                        HStack {
                            Text(app.name)
                            Spacer()
                        }
                        HStack {
                            Text(app.bundleId)
                            Spacer()
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    addItem?(app)
                    showingPanel.toggle()
                }
            }
        }
        .padding(EdgeInsets(top: 30, leading: 30, bottom: 30, trailing: 30))
        .background {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow, state: .active, emphasized: true)
        }
        .onAppear {
            appService.fetchRunningApplications()
        }
    }
}

extension FloatingPanelView {
    private func pickApplication() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let appURL = panel.url {
            guard let appBundle = Bundle(url: appURL) else {
                return
            }
            let macApp: RunningApp = RunningApp(bundleId: appBundle.identifier, name: appBundle.appName, url: appBundle.bundleURL, executableUrl: appBundle.executableURL)
            addItem?(macApp)
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State
    var emphasized: Bool
 
    func makeNSView(context: Context) -> NSVisualEffectView {
        context.coordinator.visualEffectView
    }
 
    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        context.coordinator.update(
            material: material,
            blendingMode: blendingMode,
            state: state,
            emphasized: emphasized
        )
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
 
    class Coordinator {
        let visualEffectView = NSVisualEffectView()
 
        init() {
            visualEffectView.blendingMode = .withinWindow
        }
 
        func update(material: NSVisualEffectView.Material,
                        blendingMode: NSVisualEffectView.BlendingMode,
                        state: NSVisualEffectView.State,
                        emphasized: Bool) {
            visualEffectView.material = material
            visualEffectView.blendingMode = blendingMode
            visualEffectView.state = state
            visualEffectView.isEmphasized = emphasized
        }
    }
  }
