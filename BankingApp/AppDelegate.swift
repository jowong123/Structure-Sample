//
//  AppDelegate.swift
//  BankingApp
//
//  Created by jw on 19/04/2026.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let shared: AppDelegate = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return AppDelegate()
        }
        return appDelegate
    }()
    
    func logout() {
        // cancel API
        // removeToken
        // delete user data
        // clear user defaults
        // clear background running task/tracker
        // any thrid party library tokens
        // depends what you needs and using

        if !(AppNavigator.shared.currentViewController is WSLoginViewController) {
            AppNavigator.shared.navigate(
                to: WSAuthenticationRoutes.login,
                with: .changeRoot(transitionType: .fade, transitionSubtype: .fromBottom)
            )
        }
    }
    
    func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

