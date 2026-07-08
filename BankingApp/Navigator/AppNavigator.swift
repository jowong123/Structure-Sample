//
//  AppNavigator.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation

class AppNavigator: BaseNavigator {
    static let shared = AppNavigator()

    init() {
        super.init(with: WSLandingRoutes.splash)
    }

    required init(with route: Route) {
        super.init(with: route)
    }
}
