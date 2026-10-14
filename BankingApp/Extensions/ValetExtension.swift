//
//  ValetExtensions.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//

import Foundation
import Valet

extension Valet {
    func getKeychainValue(forKey key: String) -> String {
        guard let token = try? self.string(forKey: key),
              !token.isEmpty else {
            return ""
        }

        return token
    }

    func setKeychainValue(
        _ text: String,
        forKey key: String
    ) {
        guard !text.isEmpty else {
            try? self.removeObject(forKey: key)
            return
        }

        try? self.setString(
            text,
            forKey: key
        )
    }

    func getKeychainValue(forKey key: String) -> Data? {
        guard let data = try? self.object(forKey: key),
              !data.isEmpty else {
            return nil
        }

        return data
    }

    func setKeychainValue(
        _ data: Data?,
        forKey key: String
    ) {
        guard let data = data, !data.isEmpty else {
            try? self.removeObject(forKey: key)
            return
        }

        try? self.setObject(
            data,
            forKey: key
        )
    }
}
