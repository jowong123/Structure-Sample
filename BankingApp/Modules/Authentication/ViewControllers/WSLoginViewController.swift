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
}

// MARK: - MILoginViewDelegate Methods

extension WSLoginViewController: WSLoginViewDelegate {
    func viewDidSelectLoginButton(_: WSLoginView) {
        self.postAuthenticate()
    }
}
