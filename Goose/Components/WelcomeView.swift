//
//  WelcomeView.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-27.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    var dismiss: (() -> Void)?
    var body: some View {
        VStack(alignment: .center) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledToFit()
                .frame(width: 150, alignment: .center)
            
            Text("Welcome to")
                .font(.largeTitle)

            Text("Goose")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading) {
                WelcomePoint1()
                WelcomePoint2()
                WelcomePoint3()
                WelcomePoint4()
            }
            
            Button(action: {
                dismiss?()
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.blue))
                    .padding()
            }
            .frame(maxWidth: 400)
            .buttonStyle(.link)
        }
        .padding()
        .padding(.horizontal, 40)
        .frame(width: 800, height: 600)
    }
}

fileprivate struct WelcomePoint1: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "menubar.dock.rectangle")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
                .frame(width: 80)

            VStack(alignment: .leading) {
                Text("Monitor dock for notifications")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Goose App continuously monitors pending notifications from various apps installed on your device.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

fileprivate struct WelcomePoint2: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "app.badge")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
                .frame(width: 80)

            VStack(alignment: .leading) {
                Text("Multiple ways to alert for missed notifications")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Receive notifications from Goose App whenever there are pending alerts, ensuring you stay informed and up-to-date. Goose app can trigger a sound, notification, flash or make a HTTP request")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

fileprivate struct WelcomePoint3: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "menubar.arrow.up.rectangle")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
                .frame(width: 80)

            VStack(alignment: .leading) {
                Text("Accessible menu bar shortcuts")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Easily access notifications from the menu bar, providing a convenient and centralized location for all your pending alerts.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

fileprivate struct WelcomePoint4: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "lifepreserver.fill")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
                .frame(width: 80)
            
            VStack(alignment: .leading) {
                Text("Customizable alerts")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Tailor Your Notifications: Customize Goose App to Suit Your Preferences!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
