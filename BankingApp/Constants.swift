//
//  Constants.swift
//  BankingApp
//
//  Created by jw on 21/04/2026.
//

import Foundation
import LocalAuthentication
import UIKit

enum App {
    // MARK: - Constants

    private static let enString = R.string(preferredLanguages: [WSLanguage.english.rawValue])
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    static let deviceUuidString = UIDevice.current.identifierForVendor?.uuidString ?? ""

    // MARK: - Methods

    static func version() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String else {
            return ""
        }

        return "\(version) (\(build))"
    }

    static func localizedString(language: WSLanguage = WSLanguageManager.shared.language) -> _R.string {
        switch language {
        case .english:
            return App.enString
        }
    }

    private static let apiConfig: (version: String, paths: [String: String])? = {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["Api Version"] as? String,
              let paths = dictionary["Api Url Paths"] as? [String: String] else {
            return nil
        }
        return (version, paths)
    }()

    static func configApiUrl(
        url: String,
        pathType: WSApiPathType = .active
    ) -> String {
        guard let config = apiConfig else {
            return ""
        }

        guard let urlPath = config.paths[pathType.rawValue] else {
            return "\(config.version)\(url)"
        }

        return "\(config.version)\(urlPath)\(url)"
    }
}

enum Device {
    // MARK: - Properties
    // MARK: Static

    static var isDarkMode: Bool {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return true
        } else {
            return false
        }
    }

    static var isFaceIdSupported: Bool {
        let context = LAContext()
        var error: NSError?

        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        return context.biometryType == .faceID
    }
}

enum DeviceType {
    // MARK: - Constants

    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
}

enum WSApiPathType: String {
    case active = "api-url-active"
    case none
}
