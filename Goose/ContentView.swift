//
//  ContentView.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @AppStorage("goose.hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject private var appService = AppService.shared
    @State private var showingPanel: Bool = false
    @State private var showingOnboarding: Bool = false
    @State private var showingPermissions: Bool = false
    @State private var failedToSetupObservers = false
    @State private var presentPermissions = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appService.monitoredApps) { item in
                    NavigationLink {
                        AppDetailView(item: item)
                    } label: {
                        AppMetadataView(item: item)
                    }
                }
                .onDelete(perform: { indexSet in
                    appService.deleteItems(offsets: indexSet)
                })
            }
            .toolbar {
                // Sidebar
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
                
                ToolbarItem(placement: .navigation) {
                    Image(.logo)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                // Toolbar item when permissions are denied
                ToolbarItem() {
                    if failedToSetupObservers {
                        MissingPermissionButton(presentPermissions: $presentPermissions)
                    }
                }
                
                // Add Toolbar item
                ToolbarItem() {
                    Button(action: {
                        showingPanel.toggle()
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            
            Text("Select an item")
        }
        .sheet(isPresented: $showingPanel, content: {
            FloatingPanelView(showingPanel: $showingPanel, addItem: { app in
                appService.addItem(app: app)
            })
            .frame(width: 600, height: 300)
        })
        .sheet(isPresented: $showingPermissions, content: {
            PermissionView(dismiss: {
                showingPermissions.toggle()
            })
            .frame(width: 600)
            .background {
                Color.blue
            }
        })
        .sheet(isPresented: $showingOnboarding, content: {
            WelcomeView(dismiss: {
                hasSeenOnboarding = true
                showingOnboarding.toggle()
                if !PermissionService.isAccessibilityEnabled() {
                    PermissionService.requestAccessibilityPermissions()
                    showingPermissions.toggle()
                }
            })
                .interactiveDismissDisabled()
        })
        .onReceive(PermissionService.permissionStatus, perform: { status in
            failedToSetupObservers = !status
        })
        .onAppear {
            appService.fetchMonitoredApplications()
            if !hasSeenOnboarding {
                showingOnboarding.toggle()
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView()
}
