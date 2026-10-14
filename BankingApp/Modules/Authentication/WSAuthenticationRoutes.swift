//
//  WSAuthenticationRoutes.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import UIKit
//import RswiftResources

enum WSAuthenticationRoutes: Route {
    case login
    
    var screen: UIViewController {
        switch self {
        case .login:
            return WSAuthenticationRoutesContainer.shared.buildLoginViewController()
        }
    }
    
    class WSAuthenticationRoutesContainer {
        static let shared = WSAuthenticationRoutesContainer()
        
        func buildLoginViewController() -> UIViewController {
            guard let viewController = R.storyboard.authentication.loginViewController() else {
                return UIViewController()
            }
            
            viewController.viewModel = WSLoginViewModel()
            return viewController
        }
    }
}
