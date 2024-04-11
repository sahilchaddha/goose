//
//  AboutView.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-21.
//

import Foundation
import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSImage(named: "AppIcon")!)
            
            Text("\(Bundle.main.appName)")
                .font(.system(size: 20, weight: .bold))
                .textSelection(.enabled)
            
            Text("Ver: \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild)) ")
                .textSelection(.enabled)
            HStack {
                Link("Source Code", destination: AboutView.githubUrl)
                Link("Website", destination: AboutView.websiteUrl)
                Link("Contact", destination: AboutView.twitterLink)
            }

            Text("Built with ❤️ by Sahil Chaddha")
                .font(.system(size: 12, weight: .thin))
                .multilineTextAlignment(.center)
                .onTapGesture {
                    NSWorkspace.shared.open(AboutView.twitterLink)
                }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 300)
    }
}

extension AboutView {
    private static var twitterLink: URL { URL(string: "https://x.com/sahilccc")! }
    public static var websiteUrl: URL { URL(string: "https://sahilchaddha.com/goose" )! }
    public static var githubUrl: URL { URL(string: "https://github.com/sahilchaddha/goose")! }
}
