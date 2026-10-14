//
//  WSUserDataManager.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//

import Foundation
import SwiftyJSON
import Valet

class WSUserDataManager: NSObject {
    
    static let shared = WSUserDataManager()
    
    // MARK: Private

    private lazy var tokenKeychain: Valet = {
        guard let identifier = Identifier(nonEmpty: "TokenKeychain") else {
            fatalError("Invalid TokenKeychain identifier")
        }

        return Valet.valet(
            with: identifier,
            accessibility: .afterFirstUnlock
        )
    }()

    private lazy var secretKeychain: Valet = {
        guard let identifier = Identifier(nonEmpty: "SecretKeychain") else {
            fatalError("Invalid TokenKeychain identifier")
        }

        return Valet.valet(
            with: identifier,
            accessibility: .whenUnlocked
        )
    }()
}

// MARK: - Token Keychain Storage

extension WSUserDataManager {
    
    // MARK: - Keys

    private enum TokenKeychainKey: String {
        case accessToken
        case refreshToken
        case newIspAccessToken
    }
    
    // MARK: - Properties
    // MARK: Internal
    
    var isTokenRefreshable: Bool {
        return !self.refreshToken.isEmpty
    }
    
    private(set) var accessToken: String {
        get {
            return self.tokenKeychain.getKeychainValue(forKey: TokenKeychainKey.accessToken.rawValue)
        }

        set {
            self.tokenKeychain.setKeychainValue(
                newValue,
                forKey: TokenKeychainKey.accessToken.rawValue
            )
        }
    }
    
    private(set) var refreshToken: String {
        get {
            return self.tokenKeychain.getKeychainValue(forKey: TokenKeychainKey.refreshToken.rawValue)
        }

        set {
            self.tokenKeychain.setKeychainValue(
                newValue,
                forKey: TokenKeychainKey.refreshToken.rawValue
            )
        }
    }
    
    // MARK: - Internal Methods
    
    func setTokens(
        json: JSON,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if let token = json["accessToken"].string,
           !token.isEmpty {
            accessToken = token
        }

        if let token = json["refreshToken"].string,
           !token.isEmpty {
            refreshToken = token
        }

        if isUserLogin {
            success()
        } else {
            AppDelegate.shared.logout()
            failure(ErrorHelper.unknownError)
        }
    }

    func deleteTokens() {
        try? self.tokenKeychain.removeAllObjects()
    }
}

// MARK: - Secret Keychain Storage

extension WSUserDataManager {
    // MARK: - Keys

    private enum SecretKeychainKey: String {
        case userDataSecret
    }
    
    var isUserLogin: Bool {
        return !self.accessToken.isEmpty
    }

    // MARK: - Properties
    // MARK: Private

    private var userDataSecret: Data? {
        get {
            return self.secretKeychain.getKeychainValue(forKey: SecretKeychainKey.userDataSecret.rawValue)
        }

        set {
            self.secretKeychain.setKeychainValue(
                newValue,
                forKey: SecretKeychainKey.userDataSecret.rawValue
            )
        }
    }

    // MARK: - Private Methods

    private func deleteUserDataSecret() {
        try? self.secretKeychain.removeObject(forKey: SecretKeychainKey.userDataSecret.rawValue)
    }
}

