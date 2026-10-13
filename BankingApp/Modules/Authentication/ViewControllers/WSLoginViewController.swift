//
//  WDLoginViewController.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//


import Foundation
import UIKit
import GreetingKit

class WSLoginViewController: WSBaseViewControllerWithViewModel<WSLoginViewModel> {
    // MARK: - Outlets

    @IBOutlet weak var containerView: WSLoginView!

    // MARK: - Properties
    // MARK: Override

    override var _containerView: WSBaseView {
        return self.containerView
    }

    // MARK: Internal

    var loginId: String {
        get {
            return viewModel.loginId
        }

        set {
            viewModel.loginId = newValue
        }
    }

    var password: String {
        get {
            return viewModel.password
        }

        set {
            viewModel.password = newValue
        }
    }

    var validationErrors: [WSLoginViewModel.ValidationError] {
        return viewModel.validationErrors
    }

    // MARK: - Lifecycle Events

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.containerView.delegate = self
        
        let kit = GreetingKit()
        print(kit.greet(name: "World"))
    }

    // MARK: - Private Methods
    // MARK: Helper Methods

    private func postAuthenticate() {
        // startHUD()

        viewModel.postAuthenticate(
            success: { [weak self] in
                // // self?.stopHUD()
                // setup login
                // redirection to home page
                // update credential keychain
            },
            failure: { [weak self] error in

                // self?.stopHUD()
                
                let error = error as NSError
                let errorKey = error.userInfo["errorKey"] as? String

                if error == ErrorHelper.unauthorizedError || errorKey == "E1000" {
                    let message = App.localizedString().localizable.errorInvalidUrl()
                    // update UI TextField Error State/Message
                } else if error == ErrorHelper.accountInactiveError {
                    // error message handling alert
                } else if error == ErrorHelper.accountSuspendedError {
                    // error message handling alert
                } else {
                    // error message handling alert
                }
            }
        )
    }
    
    func testConnection() {
        let url = URL(string: "https://api.github.com")!
        URLSession.shared.dataTask(with: url) { _, response, error in
            if let error = error {
                print("❌ Blocked:", error.localizedDescription)
            } else {
                print("✅ Connected:", (response as? HTTPURLResponse)?.statusCode ?? 0)
            }
        }.resume()
    }
    
    func testKeyChain() {
        let keychain = KeychainHelper.shared
        do {
            try keychain.save("my-secret-token-123", for: "accessToken")
            print("💾 Saved")

            print("📖 Read:", try keychain.read("accessToken") ?? "nil")

            try keychain.save("new-token-456", for: "accessToken")
            print("🔄 Updated:", try keychain.read("accessToken") ?? "nil")

            try keychain.delete("accessToken")
            print("🗑️ After delete:", try keychain.read("accessToken") ?? "nil")
        } catch {
            print("❌ Keychain error:", error)
        }
    }
    
    func loginAuth0() {
        AuthManager.shared.login { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Logged in. Token:", (try? KeychainHelper.shared.read("accessToken")) ?? "nil")
                    self.printIDToken()
                case .failure(let error):
                    print("❌ Login failed:", error)
                }
            }
        }
    }
    
    // Showing the user’s info. You can display “Welcome, you@email.com” or their name right after login, with no extra network request. The info is already in the token.
    
    // Knowing which user this is. The sub field is a unique, permanent user ID. Apps use it to keep data separate per user. For example, if two people log in on the same phone, you don’t mix up their saved settings or cached data.

    // Proof that login actually happened. It’s signed by the login server and includes the issuer, audience, and time, so after verifying it, the app knows this user really logged in just now, for this app. Some apps also check the auth_time field for step-up authentication (“did they log in recently enough to allow a transfer?”).

    // Logging out. When logging out of the login server, apps often send the ID token back (as id_token_hint), so the server knows which session to end.
    func printIDToken() {
        guard let token = try? KeychainHelper.shared.read("idToken") else {
            return print("No ID token saved")
        }

        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return print("Not a valid JWT") }

        // Turn Base64URL back into normal Base64
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 { payload += "=" }   // add back the removed padding

        if let data = Data(base64Encoded: payload),
           let json = String(data: data, encoding: .utf8) {
            print("🪪 ID token payload:\n", json)
        }
    }
}

// MARK: - MILoginViewDelegate Methods

extension WSLoginViewController: WSLoginViewDelegate {
    func viewDidSelectSshButton(_ view: WSLoginView) {
        self.loginAuth0()
    }
    
    func viewDidSelectLoginButton(_: WSLoginView) {
        self.postAuthenticate()
    }
}
