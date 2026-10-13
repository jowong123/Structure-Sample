//
//  PKCEHelper.swift
//  BankingApp
//
//  Created by jw on 11/10/2026.
//

import Foundation
import CryptoKit
import Security

struct PKCE {
    let verifier: String
    let challenge: String
    
    init() {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        verifier = Data(bytes).base64URLEncoded() // encoded to readable string text
        challenge = Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncoded() // hash with SHA256, pass to server
    }
}

extension Data {
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
