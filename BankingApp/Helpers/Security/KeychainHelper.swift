//
//  KeychainHelper.swift
//  BankingApp
//
//  Created by jw on 10/10/2026.
//

import Foundation
import Security
import LocalAuthentication


enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
    case invalidData
}

final class KeychainHelper {
    static let shared = KeychainHelper()
    private let service =  Bundle.main.bundleIdentifier ?? "defaultName"
    
    private func baseQuery(_ account: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }
    
    func save(_ value: String, for account: String) throws {
        let data = Data(value.utf8)
        
        // query generate with dictionary
        var query = baseQuery(account)
        query[kSecValueData as String] = data
        
        // means nvr go cloud or backups services/ other phone
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        // add item to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // check item of this query existing
        if status == errSecDuplicateItem {
            
            // write changes
            let changes: [String : Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            
            // update status as [String: Any] as CFDictionary
            let updateStatus = SecItemUpdate(baseQuery(account) as CFDictionary, changes as CFDictionary)
            
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func read(_ account: String) throws -> String? {
        // query return with one result,
        // our address can only match one item. For password-type Keychain items, the combination of service
        // plus account must be unique. You can’t have two "accessToken" items for the same app, which is
        // why save gets errSecDuplicateItem and switches to update
        //
        var query = baseQuery(account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return value
    }
    
    func delete(_ account: String) throws {
        // query
        let status = SecItemDelete(baseQuery(account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

extension KeychainHelper {
    func saveWithBiometrics(_ value: String, for account: String) throws {
        // The lock: Face ID / Touch ID required, device must have a passcode
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryCurrentSet,
            nil
        ) else {
            throw  KeychainError.invalidData
        }
        
        // remove any old item first
        try delete(account)
        
        var query = baseQuery(account)
        query[kSecValueData as String] = Data(value.utf8)
        query[kSecAttrAccessControl as String] = access
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func readWithBiometrics(
        _ account: String,
        reason: String,
        completion: @escaping (Result<String?, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let context = LAContext()
            context.localizedReason = reason
            
            var query = self.baseQuery(account)
            query[kSecReturnData as String] = true
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecUseAuthenticationContext as String] = context
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            switch status {
            case errSecSuccess:
                guard let data = result as? Data,
                      let value = String(data: data, encoding: .utf8) else {
                    return completion(.failure(KeychainError.invalidData))
                }
                completion(.success(value))
            case errSecItemNotFound:
                completion(.success(nil))
            default:
                completion(.failure(KeychainError.unexpectedStatus(status)))
            }
        }
    }
}
