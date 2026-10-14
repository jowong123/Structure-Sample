//
//  LanguageManager.swift
//  BankingApp
//
//  Created by jw on 21/04/2026.
//

import Foundation
import UIKit

enum WSLanguage: String {
    case english = "en"
}

class WSLanguageManager {
    // MARK: - Keys

    private enum Keys: String {
        case appleLanguages = "AppleLanguages"
        case language
    }

    // MARK: - Properties
    // MARK: Static

    static let shared = WSLanguageManager()

    // MARK: Internal

    var language: WSLanguage {
        get {
            guard let userDefaults = UserDefaults(suiteName: MIEnv.localizedApnsAppGroup),
                  let languageValue = userDefaults.string(forKey: Keys.language.rawValue),
                  let language = WSLanguage(rawValue: languageValue) else {
                return .english
            }

            return language
        }

        set {
            guard let userDefaults = UserDefaults(suiteName: MIEnv.localizedApnsAppGroup) else {
                return
            }

            let newLanguageValue = newValue.rawValue
            userDefaults.set(newLanguageValue, forKey: Keys.language.rawValue)
            userDefaults.synchronize()
            UserDefaults.standard.set([newLanguageValue], forKey: Keys.appleLanguages.rawValue)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(
                name: SharedApp.NotificationName.ON_USER_LANGUAGE_CHANGED,
                object: nil
            )
        }
    }

    // MARK: - Private Methods
    // MARK: Helper Methods

    private func trimLanguageKey(_ languageKey: String) -> String {
        if languageKey.hasPrefix("en") {
            return "en"
        } else if languageKey.hasPrefix("ms") {
            return "ms"
        } else {
            return languageKey
        }
    }

    // MARK: - Internal Methods

    func syncLanguage() {
        guard let userDefaults = UserDefaults(suiteName: MIEnv.localizedApnsAppGroup) else {
            return
        }

        guard let languageValue = userDefaults.string(forKey: Keys.language.rawValue),
              WSLanguage(rawValue: languageValue) != nil else {
            self.language = .english
            return
        }

        var isLanguageSet = false
        for languageValue in Locale.preferredLanguages {
            if let appleLanguage = WSLanguage(rawValue: trimLanguageKey(languageValue)) {
                self.language = appleLanguage
                isLanguageSet = true
                break
            }
        }

        if !isLanguageSet {
            self.language = .english
        }
    }
}
