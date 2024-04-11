//
//  ListItem.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-13.
//

import Foundation
import SwiftUI

struct AppMetadataView: View {
    var item: Item
    
    var body: some View {
        HStack {
            if let bundleUrl = item.bundleUrl {
                Image(nsImage: bundleUrl.bundleImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40, height: 40)
                    Text("\((item.name != nil) ? String(item.name!.prefix(1)) : "App")")
                }
            }
            VStack {
                HStack {
                    Text(item.name ?? "AppName")
                    Spacer()
                }
                HStack {
                    Text(item.bundleId ?? "BundleID")
                    Spacer()
                }
            }
            Spacer()
        }
    }
}

