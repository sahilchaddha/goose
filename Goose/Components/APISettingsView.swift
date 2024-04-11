//
//  APISettingsView.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-22.
//

import Foundation
import SwiftUI
import CodeViewer

struct APISettingsView: View {
    @AppStorage("goose.httpRequest") private var callApi: Bool = false
    @AppStorage("goose.requestUrl") private var requestUrl: String = ""
    @AppStorage("goose.requestMethod") private var requestMethod = "POST"
    @AppStorage("goose.requestBody") private var requestBody = """
{
    "text": "$ALERT"
}
"""
    
    let pickerValues = ["GET", "POST", "PUT", "DELETE"]
    @ViewBuilder
    func pickerContent() -> some View {
        ForEach(pickerValues, id: \.self) {
            Text($0)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $callApi, label: {
                    Text("Make HTTP request on alert")
                })
                Spacer()
            }
            if callApi {
                VStack {
                    
                    // HTTP Method
                    HStack {
                        Picker("Method :", selection: $requestMethod) {
                            pickerContent()
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .frame(width: 150)
                        Spacer()
                    }
                    
                    // HTTP URL
                    HStack {
                        Text("URL :")
                        TextField("https://slack.com/webhook", text: $requestUrl)
                    }
                    .padding(.vertical)
                    
                    if requestMethod != "GET" {
                        // HTTP Body
                        HStack {
                            Text("Body :")
                            CodeViewer(
                                content: $requestBody,
                                mode: .json,
                                darkTheme: .solarized_dark,
                                lightTheme: .solarized_light,
                                fontSize: 12
                            )
                            .frame(height: 150)
                        }
                        HStack {
                            Text("$ALERT: This token is replaced with actual notification message. Example : Unread Slack Notifications: 10")
                                .font(.caption)
                                .padding(.vertical)
                            Spacer()
                        }

                    }
                }
                .padding(.vertical)
            }
            Spacer()
        }
        .padding()
    }
}
