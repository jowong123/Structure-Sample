//
//  AuthenticationServices.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import SwiftyJSON
import Alamofire

// PLEASE DO NOT CALL, IT WONT WORK, IS A EXAMPLE OF API CALLING WORK

class AuthenticationServices: AuthenticationServicesProtocol {
    // MARK: - Paths
    
    let postAuthenticateUrl = "/authenticate".apiPrefix(.active)
    
    // MARK: - Request Call Methods

    func postAuthenticate(
        params: [String: Any],
        success: @escaping (JSON) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        _ = APIClient.request(
            .post,
            url: self.postAuthenticateUrl,
            params: params,
            authorizationType: .none,
            isResponseDataNullable: true,
            success: { object, _ in
                if let json = object?["data"] as? JSON {
                    success(json)
                } else {
                    failure(ErrorHelper.unknownError)
                }
            },
            failure: failure
        )
    }
}
