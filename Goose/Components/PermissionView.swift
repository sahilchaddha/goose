//
//  PermissionView.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-04-01.
//

import Foundation
import SwiftUI
let settingsUrl: URL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!

struct PermissionView: View {
    var dismiss: (() -> Void)?
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Permissions Required 🔐")
                    .font(.largeTitle)
            }
            .padding()
            HStack(alignment: .center) {
                Text("macOS requires that Goose app has accessibility permissions granted to it in order to monitor the dock for notifications.")
                    .multilineTextAlignment(.center)
                    .font(.body)
            }
            .padding()
            HStack(alignment: .center) {
                if Sandbox.isSandboxingEnabled() {
                    Text("You will need to manually add Goose app under System Settings -> Privacy -> Accessibility. You can open System Settings by tapping the button below :")
                        .multilineTextAlignment(.center)
                        .font(.body)
                } else {
                    Text("You should have already been prompted by macOS to grant these permissions but if not, you can manually open system settings to add Goose app to the allowlist.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                }
            }
            .padding()
            if !Sandbox.isSandboxingEnabled() {
                HStack(alignment: .center, content: {
                    Button("Request Accessibility Permission") {
                        PermissionService.requestAccessibilityPermissions()
                    }
                    .buttonStyle(.plain)
                    .padding()
                })
                .background {
                    Color.black
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            HStack(alignment: .center, content: {
                Button("Open System Preferences") {
                    NSWorkspace.shared.open(settingsUrl)
                }
                .buttonStyle(.plain)
                .padding()
            })
            .background {
                Color.black
                    .opacity(0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            HStack(alignment: .center) {
                Text("This dialog will automatically be removed within a few seconds of the permission being granted.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
            }
            .padding()
        }
        .padding()
        .background(content: {
            Color.blue
                .ignoresSafeArea()
        })
        .onReceive(PermissionService.permissionStatus, perform: { status in
            if status {
                dismiss?()
            }
        })
    }
        
}


#Preview {
    PermissionView()
        .frame(width: 600)
        .background {
            Color.blue
        }
}
