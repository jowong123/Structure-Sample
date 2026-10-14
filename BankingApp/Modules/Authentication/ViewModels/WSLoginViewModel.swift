//
//  WSLoginViewModel.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import SwiftyJSON

class WSLoginViewModel {
    
    // MARK: Enum

    enum ValidationError: Error {
        case invalidLoginIdLength
        case invalidPasswordLength
    }

    // MARK: - Properties
    // MARK: Private

    private let authenticationServices: AuthenticationServicesProtocol

    // MARK: Internal

    var validationErrors: [ValidationError] {
        var errors: [ValidationError] = []

        if !self.loginId.isUsernameLengthValid() {
            errors.append(.invalidLoginIdLength)
        }

        if !self.password.isPasswordLengthValid() {
            errors.append(.invalidPasswordLength)
        }

        return errors
    }

    var loginId: String = ""
    var password: String = ""

    // MARK: - Initializer

    init(authenticationServices: AuthenticationServicesProtocol = AuthenticationServices()) {
        self.authenticationServices = authenticationServices
    }

    // MARK: - Internal Methods
    // MARK: API Services Methods

    func postAuthenticate(
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if let firstError = self.validationErrors.first {
            failure(firstError)
            return
        }
        
        let params = [
            "loginId": loginId.lowercased(),
            "password": self.password,
            "rememberMe": true,
        ] as [String: Any]

        self.authenticationServices.postAuthenticate(
            params: params,
            success: { json in
                if let isInactive = json["inactive"].bool,
                   isInactive {
                    failure(ErrorHelper.accountInactiveError)
                } else if let isSuspended = json["suspended"].bool,
                          isSuspended {
                    failure(ErrorHelper.accountSuspendedError)
                } else if let isFirstTimeLogin = json["firstTimeLogin"].bool,
                          isFirstTimeLogin {
                    failure(ErrorHelper.accountFirstTimeLoginError)
                } else {
                    WSUserDataManager.shared.deleteTokens()
                    WSUserDataManager.shared.setTokens(
                        json: json,
                        success: success,
                        failure: failure
                    )
                }
            },
            failure: failure
        )
    }
}
