//
//  AuthenticationMockServices.swift
//  BankingApp
//
//  Created by jw on 03/10/2026.
//

import SwiftyJSON
@testable import BankingApp

class AuthenticationMockServices: AuthenticationServicesProtocol {
    // MARK: Properties
    
    let isOtpSent: Bool
    let loginType: LoginType?
    let otpType: OtpType?
    
    
    // MARK: - Initializer
    
    init(
        isOtpSent: Bool = false,
        loginType: LoginType? = nil,
        otpType: OtpType? = nil,
    ) {
        self.isOtpSent = isOtpSent
        self.loginType = loginType
        self.otpType = otpType
    }
    
    // MARK: - Request Call Methods
    
    // LoginType decide which file to use as api mock data
    func postAuthenticate(
        params: [String : Any],
        success: @escaping (JSON) -> Void,
        failure: @escaping (any Error) -> Void
    ) {
        var fileName = "PostAuthenticateResponseJson-"
        fileName += self.loginType!.rawValue
        
        let json = JSON.generateJSON(fileName: fileName)!
        success(json)
    }
}
