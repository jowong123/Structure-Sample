//
//  SharedConstants.swift
//  BankingApp
//
//  Created by jw on 21/04/2026.
//

import Foundation

enum MIEnv: String {
    // MARK: - Cases

    case dev = "DEV"

    // MARK: - Keys

    enum Keys: String {
        case env = "Env"
        case baseUrl = "Base URL"
        case localizedApnsAppGroup = "Localized Apns App Group"
    }

    // MARK: - Properties
    // MARK: Private Static

    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError(".plist file not found.")
        }
        return dict
    }()

    // MARK: Internal Static

    static var currentEnv: MIEnv = {
        guard let envString = infoDict[Keys.env.rawValue] as? String,
              let env = MIEnv(rawValue: envString) else {
            fatalError("Env not set in .plist file.")
        }
        return env
    }()

    static var baseUrl: String = {
        guard let url = infoDict[Keys.baseUrl.rawValue] as? String else {
            fatalError("Base URL not set in .plist file.")
        }
        return "https://\(url)"
    }()
    
    static var localizedApnsAppGroup: String = {
        guard let appGroup = infoDict[Keys.localizedApnsAppGroup.rawValue] as? String else {
            fatalError("Localized Apns App Group not set in .plist file.")
        }
        return appGroup
    }()
    
}

enum SharedApp {
    // MARK: - Notfication Name

    enum NotificationName {
        static let ON_REACHABILITY_CHANGED = Notification.Name("onReachabilityChanged")
        static let ON_USER_LANGUAGE_CHANGED = Notification.Name("onUserLanguageChanged")
        static let CHANGE_MAIN_TAB_INDEX = Notification.Name("changeMainTabIndex")
        static let ON_KEYBOARD_WILL_SHOW = Notification.Name("onKeyboardWillShow")
        static let ON_KEYBOARD_WILL_HIDE = Notification.Name("onKeyboardWillHide")
        static let ON_KEYBOARD_WILL_CHANGE_FRAME = Notification.Name("onKeyboardWillChangeFrame")
    }
}
