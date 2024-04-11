//
//  StatusItem.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-17.
//

import Foundation
import Combine
import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

public struct StatusItemInfo {
    let url: String
    let badge: String
}

struct StatusItem: View {
    var sizePassthrough: PassthroughSubject<CGSize, Never>
    @State private var menuShown: Bool = false
    @StateObject private var appService = AppService.shared
    @AppStorage("goose.statusIconSize") private var statusIconSize = "Small"
    
    func getItemHeight() -> CGFloat {
        if statusIconSize == "Small" {
            return 20
        } else if statusIconSize == "Medium" {
            return 25
        } else {
            return 30
        }
    }
    @ViewBuilder
    var mainContent: some View {
        HStack(spacing: 0) {
            ForEach(appService.statusIcons, id: \.url) { item in
                Button(action: {
                    if let bundle = item.url.bundle() {
                        NSWorkspace.shared.open(bundle.bundleURL)
                    }
                }, label: {
                    ZStack {
                        Image(nsImage: item.url.bundleImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: getItemHeight(), height: getItemHeight())
                        if !item.badge.isEmpty {
                            
                            if let badgeNumber = Int(item.badge),
                                badgeNumber > 99 {
                                Text("99+")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(.red)
                                    .clipShape(Circle())
                                    .position(CGPoint(x: getItemHeight(), y: getItemHeight()/1.5))
                            } else {
                                Text("\(item.badge)")
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(.red)
                                    .clipShape(Circle())
                                    .position(CGPoint(x: getItemHeight(), y: getItemHeight()/1.5))
                            }
                        }
                    }
                })
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
            }
            
            Image(.logo)
                .resizable()
                .frame(width: getItemHeight(), height: getItemHeight())
                .padding(.trailing, 5)
        }
        .fixedSize()
    }
    
    var body: some View {
        mainContent
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: { size in
                sizePassthrough.send(size)
            })
    }
}

struct StatusItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.3 : 0))
            )
    }
}

#Preview {
    StatusItem(sizePassthrough: PassthroughSubject<CGSize, Never>())
}
