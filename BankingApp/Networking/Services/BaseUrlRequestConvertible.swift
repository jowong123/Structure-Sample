//
//  BaseUrlRequestConvertible.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//


import Alamofire
import Foundation

struct BaseURLConvertible: URLConvertible {
    // MARK: - Properties

    let path: String
    let baseUrl: String

    // MARK: - Initializer

    init(
        path: String,
        baseUrl: String = "baseUrl"
    ) {
        self.path = path
        self.baseUrl = baseUrl
    }

    // MARK: - Internal Methods

    func asURL() throws -> URL {
        let urlString = "\(baseUrl)\(path)"

        guard let url = URL(string: urlString) else {
            throw ErrorHelper.unknownError
        }

        return url
    }
}

struct BaseURLRequestConvertible: URLRequestConvertible {
    // MARK: - Properties

    let url: BaseURLConvertible
    let method: HTTPMethod
    let params: Parameters?
    let bodyData: Data?
    let query: Parameters?
    let headers: HTTPHeaders
    let timeoutInterval: TimeInterval?

    // MARK: - Initializer

    init(
        path: String,
        baseUrl: String = "baseUrl",
        method: HTTPMethod,
        headers: [String: String] = [:],
        params: [String: Any]? = nil,
        bodyData: Data? = nil,
        query: [String: Any]? = nil,
        timeoutInterval: TimeInterval? = nil
    ) {
        self.url = BaseURLConvertible(path: path, baseUrl: baseUrl)
        self.method = method
        self.headers = HTTPHeaders(headers)
        self.params = params
        self.bodyData = bodyData
        self.query = query
        self.timeoutInterval = timeoutInterval
    }

    // MARK: - Internal Methods

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(
            url: url,
            method: method,
            headers: headers
        )

        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }

        if let params = params {
            request = try JSONEncoding.default.encode(request, with: params)
        }

        if let bodyData = bodyData {
            request.httpBody = bodyData
        }

        if let query = query {
            request = try URLEncoding(destination: .queryString).encode(request, with: query)
        }

        return request
    }

    func withNewHeaderAccessToken() -> BaseURLRequestConvertible {
        var newHeaders = self.headers
        
        newHeaders.update(
            name: APIClient.HTTPHeader.authorization.rawValue,
            value: "Bearer \(WSUserDataManager.shared.accessToken)"
        )

        return BaseURLRequestConvertible(
            path: self.url.path,
            baseUrl: self.url.baseUrl,
            method: self.method,
            headers: newHeaders.dictionary,
            params: self.params,
            bodyData: self.bodyData,
            query: self.query
        )
    }
}
