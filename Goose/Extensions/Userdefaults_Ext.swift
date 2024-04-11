//
//  Userdefaults_Ext.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-25.
//

import Foundation

extension UserDefaults {
    public static var checkInterval: String = UserDefaults.standard.value(forKey: "goose.interval") as? String ?? "10"
    public static var notificationInterval: String = UserDefaults.standard.value(forKey: "goose.notificationInterval") as? String ?? "3"
    public static var requestType: String = UserDefaults.standard.value(forKey: "goose.requestMethod") as? String ?? "POST"
    public static var requestBody: String = UserDefaults.standard.value(forKey: "goose.requestBody") as? String ?? ""
    public static var requestEndpoint: String? = UserDefaults.standard.value(forKey: "goose.requestUrl") as? String
    public static var httpRequest: Bool = UserDefaults.standard.bool(forKey: "goose.httpRequest")
    public static var hideIconIfEmpty: Bool = UserDefaults.standard.bool(forKey: "goose.hideIconIfEmpty")
}
