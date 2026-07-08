//
//  AuthenticationServiceProtocols.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import SwiftyJSON

protocol AuthenticationServicesProtocol {
    func postAuthenticate(
        params: [String: Any],
        success: @escaping (JSON) -> Void,
        failure: @escaping (_ error: Error) -> Void
    )
}
