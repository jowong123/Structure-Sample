//
//  AuthManager.swift
//  BankingApp
//
//  Created by jw on 11/10/2026.
//

import UIKit
import AuthenticationServices

enum AuthError: Error {
    case invalidCallback
    case tokenExchangeFailed
}

struct TokenResponse: Decodable {
    let accessToken: String
    let idToken: String?
    let refreshToken: String?
    let expiresIn: Int?
}

final class AuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthManager()

    private let domain = "dev-8zjnyjxv235but3t.us.auth0.com"
    private let clientID = "LyHAjZkIbb2xWht5WwtgSn50nGzK2g3C"
    private let redirectURI = "bankapp://callback"
    private let callbackScheme = "bankapp"
    
    private var session: ASWebAuthenticationSession?

    func login(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let pkce = PKCE()
        let state = UUID().uuidString
        
        var components = URLComponents(string: "https://\(domain)/authorize")!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "openid profile email offline_access"), // openid turn on OIDC
            URLQueryItem(name: "code_challenge", value: pkce.challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state)
        ]
        
        let handler: ASWebAuthenticationSession.CompletionHandler = { [weak self] callbackURL, error in
            if let error = error { return completion(.failure(error)) }
            
            // check return state == app generated state and return authorization code
            guard let callbackURL = callbackURL,
                      let items = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
                      items.first(where: { $0.name == "state" })?.value == state,
                      let code = items.first(where: { $0.name == "code" })?.value
                else { return completion(.failure(AuthError.invalidCallback)) }

                self?.exchange(code: code, verifier: pkce.verifier, completion: completion)
        }
        
        //The new API also supports .https(host:path:) callbacks, which use Universal Links instead of a custom scheme like bankapp://. That’s more secure, because any app can register the bankapp:// scheme, but only your app can own your verified web domain. It needs a website with an apple-app-site-association file, so for your portfolio .customScheme is fine. Mentioning that you know about the difference will impress interviewers.
        
        //With bankapp://, any app on the phone can register the same scheme. A malicious app could claim bankapp:// too and try to catch the login code. (PKCE limits the damage, since they don’t have the verifier, but it’s still a weakness.)
        
        //With https://yourbank.com, iOS checks the file on your website and the entitlement in your app. They must match, so only your app can receive that callback. Apple verifies it, and no other app can fake it.

        // For your portfolio, .customScheme is fine since you don’t have a domain. In an interview, you can just say: “In production I’d use an HTTPS callback with associated domains, because custom URL schemes can be claimed by other apps.”
        
        //callback: .https(host: "url.com", path: "/callback")
        session = ASWebAuthenticationSession(
            url: components.url!,
            callback: .customScheme(callbackScheme),
            completionHandler: handler
        )
        session?.presentationContextProvider = self
        session?.prefersEphemeralWebBrowserSession = true   // don't share browser cookies
        session?.start()
    }
    
    private func exchange(
        code: String,
        verifier: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var request = URLRequest(url: URL(string: "https://\(domain)/oauth/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code_verifier", value: verifier)
        ]
        request.httpBody = body.percentEncodedQuery?.data(using: .utf8)
        
        URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let data = data,
                  let tokens = try? decoder.decode(TokenResponse.self, from: data) else {
                return completion(.failure(AuthError.tokenExchangeFailed))
            }
            
            do {
                let keychain = KeychainHelper.shared
                try keychain.save(tokens.accessToken, for: "accessToken")
                
                if let idToken = tokens.idToken {
                    try keychain.save(idToken, for: "idToken")
                }
                
                if let refreshToken = tokens.refreshToken {
                    try keychain.save(refreshToken, for: "refreshToken")
                }
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first!
        return scene.keyWindow ?? UIWindow(windowScene: scene)
    }
}


