//
//  ApiClient.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//

import Alamofire
import Foundation
import os
import SwiftyJSON

public typealias SuccessCallback = (
    _ responseObject: [AnyHashable: Any]?,
    _ responseHeaders: HTTPHeaders
) -> Void

public typealias FailureCallback = (_ error: Error) -> Void

enum APIClient {
    // MARK: - Headers Enums

    enum HTTPHeader: String {
        case accept = "Accept"
        case contentType = "Content-Type"
        case authorization = "Authorization"
    }

    enum HTTPAuthorizationType {
        case accessToken(token: String)
        case refreshToken(token: String)
        case resetToken(token: String)
        case none
    }
    
    // MARK: - Properties
    // MARK: Private Static

    private static var logger: Any? {
        #if DEBUG
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                return nil
            }

            return Logger(subsystem: bundleIdentifier, category: "APIClient")
        #else
            return nil
        #endif
    }
    
    private static let emptyDataStatusCodes: Set<Int> = [
        204,
        205,
    ]
    private static let unauthorizedStatusCodes: Set<Int> = [
        401,
    ]
    private static let badGatewayStatusCodes: Set<Int> = [
        502,
        503,
    ]
    
    private static let session = Session.default
    private static let refreshQueue = DispatchQueue(label: "com.er.myinspector.apiclient.tokenrefresh")
    private static var isRefreshing = false
    private static var pendingRequestsWhileRefreshing: [(success: () -> Void, failure: (Error) -> Void)] = []
    
    // MARK: Internal Static

    static let baseHeaders: [String: String] = [
        HTTPHeader.accept.rawValue: "application/json",
        HTTPHeader.contentType.rawValue: "application/json",
    ]
    
    // MARK: - Internal Static Methods
    // MARK: Request Methods
    
    static func request(
        _ method: HTTPMethod,
        url: String,
        query: [String: Any]? = nil,
        params: [String: Any]? = nil,
        timeoutInterval: TimeInterval? = nil,
        bodyData: Data? = nil,
        customHeader: HTTPHeaders? = nil,
        authorizationType: HTTPAuthorizationType = .accessToken(token: WSUserDataManager.shared.accessToken),
        isResponseDataNullable: Bool = false,
        hasBaseUrl: Bool = true,
        success: @escaping SuccessCallback,
        failure: @escaping FailureCallback
    ) -> DataRequest {
        let headers = APIClient.getHeaders(
            authorizationType: authorizationType,
            customHeader: customHeader
        )

        let requestConvertible = BaseURLRequestConvertible(
            path: url,
            baseUrl: hasBaseUrl ? APIClient.getBaseUrl() : "",
            method: method,
            headers: headers,
            params: params,
            bodyData: bodyData,
            query: query,
            timeoutInterval: timeoutInterval
        )

        var shouldRefreshToken = false
        if WSUserDataManager.shared.isTokenRefreshable {
            switch authorizationType {
            case .accessToken:
                shouldRefreshToken = true
            default:
                break
            }
        }
        return self.callRequest(
            requestConvertible: requestConvertible,
            shouldRefreshToken: shouldRefreshToken,
            isResponseDataNullable: isResponseDataNullable,
            success: success,
            failure: failure
        )
    }
    
    // MARK: Helper Methods

    static func getBaseUrl() -> String {
        return "baseUrl"
    }
    
    private static func callRequest(
        requestConvertible: BaseURLRequestConvertible,
        shouldRefreshToken: Bool,
        isResponseDataNullable: Bool,
        success: @escaping SuccessCallback,
        failure: @escaping FailureCallback
    ) -> DataRequest {
        let request = self.session.request(requestConvertible)

        return request.responseData { result in
            self.log(
                message: result.debugDescription,
                statusCode: result.response?.statusCode
            )

            let refreshTokenSuccess = {
                _ = self.callRequest(
                    requestConvertible: requestConvertible.withNewHeaderAccessToken(),
                    shouldRefreshToken: false,
                    isResponseDataNullable: isResponseDataNullable,
                    success: success,
                    failure: failure
                )
            }

            self.validateResponse(
                requestConvertible: requestConvertible,
                result: result,
                shouldRefreshToken: shouldRefreshToken,
                isResponseDataNullable: isResponseDataNullable,
                refreshTokenSuccess: refreshTokenSuccess,
                success: success,
                failure: failure
            )
        }
    }
    
    // MARK: Response Validating Methods

    private static func validateResponse(
        requestConvertible: BaseURLRequestConvertible,
        result: AFDataResponse<Data>,
        shouldRefreshToken: Bool,
        isResponseDataNullable: Bool,
        refreshTokenSuccess: @escaping () -> Void,
        success: @escaping SuccessCallback,
        failure: @escaping FailureCallback
    ) {
        if let error = result.error,
           error.isExplicitlyCancelledError {
            return
        }

        guard let response = validateEmptyResponse(
            response: result.response,
            error: result.error,
            failure: failure
        ) else { return }

        guard let response = validateInvalidHttpStatusCodeResponse(
            response: response,
            failure: failure
        ) else { return }

        self.validateData(
            requestConvertible: requestConvertible,
            result: result,
            response: response,
            isResponseDataNullable: isResponseDataNullable,
            shouldRefreshToken: shouldRefreshToken,
            refreshTokenSuccess: refreshTokenSuccess,
            success: success,
            failure: failure
        )
    }
    
    private static func validateEmptyResponse(
        response: HTTPURLResponse?,
        error: AFError?,
        failure: @escaping FailureCallback
    ) -> HTTPURLResponse? {
        guard let response = response else {
            if !ReachabilityManager.shared.isReachable {
                failure(ErrorHelper.offlineError)
            } else if let error = error {
                failure(error)
            } else {
                if let logger = logger as? Logger {
                    logger.error("Request failed with no response and no error")
                }

                failure(ErrorHelper.emptyResponseError)
            }
            return nil
        }

        return response
    }
    
    private static func validateInvalidHttpStatusCodeResponse(
        response: HTTPURLResponse,
        failure: @escaping FailureCallback
    ) -> HTTPURLResponse? {
        if response.statusCode == 504 {
            failure(ErrorHelper.gatewayTimeoutError)
            return nil
        }
        return response
    }
    
    // MARK: Helper Methods

    private static func getHeaders(
        authorizationType: HTTPAuthorizationType,
        customHeader: HTTPHeaders? = nil
    ) -> [String: String] {
        var headers = self.baseHeaders

        switch authorizationType {
        case .accessToken(let token):
            headers[HTTPHeader.authorization.rawValue] = "Bearer \(token)"
        case .refreshToken(let token):
            headers[HTTPHeader.authorization.rawValue] = "Bearer \(token)"
        case .resetToken(let token):
            headers[HTTPHeader.authorization.rawValue] = "Bearer \(token)"
        default:
            break
        }

        guard let customHeader = customHeader else {
            return headers
        }

        for (key, value) in customHeader.dictionary {
            headers[key] = value
        }

        return headers
    }
    
    private static func log(
        message: String,
        statusCode: Int?
    ) {
        guard let logger = logger as? Logger else {
            return
        }

        var prefix = "📗"
        if let statusCode = statusCode {
            if statusCode < 200 || statusCode > 299 {
                prefix = "📙"
            }
        } else {
            prefix = "📕"
        }

        logger.debug("\(prefix)\n\(message)")
    }
    
    private static func validateData(
        requestConvertible: BaseURLRequestConvertible,
        result: AFDataResponse<Data>,
        response: HTTPURLResponse,
        isResponseDataNullable: Bool,
        shouldRefreshToken: Bool,
        refreshTokenSuccess: @escaping () -> Void,
        success: @escaping SuccessCallback,
        failure: @escaping FailureCallback
    ) {
        var json: JSON?
        var serializationError: NSError?

        let requestHeaders = requestConvertible.headers
        let data = result.data
        let error = isResponseDataNullable ? nil : result.error
        let contentType = response.headers[APIClient.HTTPHeader.contentType.rawValue] ?? ""
        
        // call validateEmptyData function
        // call validateBadGatewayResponse function
        // depends what you want to validate

        if let errorOcurred = APIClient.handleError(
            statusCode: response.statusCode,
            json: json
        ) ?? error as NSError? {
            let errorKey = errorOcurred.userInfo["errorKey"] as? String ?? ""

            failure(errorOcurred)
            return
        }

        if let serializationError = serializationError {
            // Check for JSON serialization errors if any data received
            failure(serializationError)
        } else {
            // Successful API Request Calling
            var responseObject: [AnyHashable: Any] = [:]
            if let json = json {
                responseObject["data"] = json
            }

            success(responseObject, response.headers)
        }
    }
    
    private static func handleError(
        statusCode: Int,
        json: JSON?
    ) -> NSError? {
        if statusCode < 200 || statusCode > 299 {
            let errorKey = json?["errorKey"].string ?? ""
            let title = json?["title"].string ?? ""
            let detail = json?["detail"].string ?? ""

            if statusCode == 404, errorKey.isEmpty {
                return ErrorHelper.notFoundError
            } else {
                return ErrorHelper.error(
                    domain: .generic,
                    code: json?["status"].int ?? statusCode,
                    errorKey: errorKey,
                    localizedDescription: title.isEmpty ? detail : title
                )
            }
        }
        return nil
    }
}
