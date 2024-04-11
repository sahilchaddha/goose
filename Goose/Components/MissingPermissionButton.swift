//
//  MissingPermissionButton.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import SwiftUI
import Cocoa

struct MissingPermissionButton: View {
    @Binding var presentPermissions: Bool
    
    var body: some View {
        Button {
            presentPermissions.toggle()
        } label: {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .foregroundColor(Color.yellow)
        }.sheet(isPresented: $presentPermissions) {
            PermissionView(dismiss: {
                presentPermissions.toggle()
            })
                .frame(width: 600)
                .background {
                    Color.blue
                }
        }

    }
}




