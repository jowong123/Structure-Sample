//
//  ErrorHelper.swift
//  BankingApp
//
//  Created by jw on 21/04/2026.
//

import Foundation
import Alamofire

enum ErrorHelper {
    // MARK: - Enum

    enum ErrorDomain: String {
        case generic = "GenericError"
        case httpStatusCode = "HttpStatusCodeError"
        case data = "DataError"
        case authentication = "AuthenticationError"
        case emptyResponseError = "EmptyResponseError"
    }

    // MARK: - Constants

    static var unknownError: NSError {
        return ErrorHelper.error(
            domain: .generic,
            localizedDescription: App.localizedString().localizable.errorUnknown()
        )
    }

    static var invalidUrlError: NSError {
        return ErrorHelper.error(
            domain: .generic,
            localizedDescription: App.localizedString().localizable.errorInvalidUrl()
        )
    }

    static var offlineError: NSError {
        return ErrorHelper.error(
            domain: .generic,
            localizedDescription: App.localizedString().localizable.errorOffline()
        )
    }

    static var notFoundError: NSError {
        return ErrorHelper.error(
            domain: .httpStatusCode,
            code: 404,
            localizedDescription: App.localizedString().localizable.errorNotFound()
        )
    }

    static var badGatewayError: NSError {
        return ErrorHelper.error(
            domain: .httpStatusCode,
            code: 502,
            localizedDescription: App.localizedString().localizable.errorBadGateway()
        )
    }

    static var gatewayTimeoutError: NSError {
        return ErrorHelper.error(
            domain: .httpStatusCode,
            code: 504,
            localizedDescription: App.localizedString().localizable.errorGatewayTimeout()
        )
    }

    static var sessionExpiredError: NSError {
        return ErrorHelper.error(
            domain: .authentication,
            localizedDescription: App.localizedString().localizable.errorSessionExpired()
        )
    }

    static var unauthorizedError: NSError {
        return ErrorHelper.error(
            domain: .authentication,
            localizedDescription: App.localizedString().localizable.errorUnauthorized()
        )
    }
    
    static var emptyResponseError: NSError {
        return ErrorHelper.error(
            domain: .data,
            localizedDescription: App.localizedString().localizable.errorEmptyResponse()
        )
    }
    
    static var accountInactiveError: NSError {
        return ErrorHelper.error(
            domain: .authentication,
            localizedDescription: App.localizedString().localizable.errorAccountInactiveError()
        )
    }
    
    static var accountSuspendedError: NSError {
        return ErrorHelper.error(
            domain: .authentication,
            localizedDescription: App.localizedString().localizable.errorAccountSuspendedError()
        )
    }
    
    static var accountFirstTimeLoginError: NSError {
        return ErrorHelper.error(
            domain: .authentication,
            localizedDescription: App.localizedString().localizable.errorAccountFirstTimeLogin()
        )
    }

    // MARK: - Methods

    static func error(
        domain: ErrorDomain = .generic,
        code: Int = 0,
        errorKey: String = "",
        localizedDescription: String = ""
    ) -> NSError {
        let userInfo = [
            NSLocalizedDescriptionKey: localizedDescription,
            "errorKey": errorKey,
        ]

        return NSError(
            domain: App.bundleIdentifier + "." + domain.rawValue,
            code: code,
            userInfo: userInfo
        )
    }

    static func isNetworkError(_ error: Error) -> Bool {
        if let urlError = (error as? URLError) ?? (error.asAFError?.underlyingError as? URLError) {
            let networkErrorCodes: Set<URLError.Code> = [
                .timedOut,
                .notConnectedToInternet,
                .networkConnectionLost,
                .cannotConnectToHost,
                .cannotFindHost,
                .dataNotAllowed,
                .internationalRoamingOff,
                .dnsLookupFailed,
                .callIsActive,
            ]
            return networkErrorCodes.contains(urlError.code)
        }
        return false
    }
}
