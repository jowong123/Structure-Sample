//
//  WSSplashViewController.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//

import Foundation
import UIKit

class WSSplashViewController: WSBaseViewController {
    
    // MARK: - Lifecycle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .primaryGreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        redirectLogin()
    }
    
    private func redirectLogin() {
        AppNavigator.shared.navigate(
            to: WSAuthenticationRoutes.login,
            with: .changeRoot(transitionType: .fade, transitionSubtype: .fromBottom)
        )
    }
}
