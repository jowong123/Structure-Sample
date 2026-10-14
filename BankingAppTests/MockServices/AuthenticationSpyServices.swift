//
//  AuthenticationSpyServices.swift
//  BankingApp
//
//  Created by jw on 04/10/2026.
//
import SwiftyJSON
@testable import BankingApp
import Foundation

class AuthenticationSpyServices: AuthenticationServicesProtocol {
    // MARK: Properties
    
    let isOtpSent: Bool
    let loginType: LoginType?
    let otpType: OtpType?
    
    // MARK: - Spy Recordings
    
    var errorToReturn: Error?
    
    private(set) var postAuthenticateCallCount = 0
    private(set) var lastPostAuthenticateParams: [String: Any]?
    
    // MARK: Initializer
    
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
    
    func postAuthenticate(
        params: [String : Any],
        success: @escaping (JSON) -> Void,
        failure: @escaping (any Error) -> Void
    ) {
        self.postAuthenticateCallCount += 1
        self.lastPostAuthenticateParams = params

        if let errorReturn = self.errorToReturn {
            failure(errorReturn)
            return
        }
        
        // return mock JSON based on loginType
        // no force unwarp: a missing loginType fails the request instead of crashing test
        
        guard let loginType = self.loginType,
              let json = JSON.generateJSON(fileName: "PostAuthenticateResponseJson-" + loginType.rawValue) else {
            
                failure(
                    NSError(
                        domain: "AuthenticationSpyServices",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Mock not configed: set loginType or mock JSON file is missing"]
                    )
                )
            return
        }
        
        success(json)
    }
}
