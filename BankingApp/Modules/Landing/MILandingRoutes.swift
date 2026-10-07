//
//  MILandingRoutes.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import UIKit
//import RswiftResources

enum WSLandingRoutes: Route {
    case splash

    var screen: UIViewController {
        switch self {
        case .splash:
            return WSLandingRoutesContainer.shared.buildSplashViewController()
        }
    }
}

class WSLandingRoutesContainer {
    static let shared = WSLandingRoutesContainer()

    func buildSplashViewController() -> UIViewController {
        guard let viewController = R.storyboard.main.splashViewController() else {
            return UIViewController()
        }

        return viewController
    }
}
