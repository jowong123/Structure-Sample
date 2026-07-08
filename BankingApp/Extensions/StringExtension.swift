//
//  StringExtension.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

extension String {
    
    func isUsernameLengthValid() -> Bool {
        if self.count >= 6, self.count <= 50 {
            return true
        } else {
            return false
        }
    }

    func isPasswordLengthValid() -> Bool {
        if self.count >= 8, self.count <= 20 {
            return true
        } else {
            return false
        }
    }

    func apiPrefix(_ type: WSApiPathType = .active) -> String {
        return App.configApiUrl(url: self, pathType: type)
    }
}
