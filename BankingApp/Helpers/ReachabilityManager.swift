//
//  ReachabilityManager.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//

import Alamofire
import Foundation
import Network

class ReachabilityManager {
    // MARK: - Properties
    // MARK: Static

    static let shared = ReachabilityManager()

    // MARK: Private

    private let reachabilityManager = NetworkReachabilityManager()

    // MARK: Internal

    var isReachable: Bool {
        return self.reachabilityManager?.isReachable ?? false
    }

    var enable = false {
        didSet {
            if self.enable {
                self.startReachabilityObserver()
            } else {
                self.removeReachabilityObserver()
            }
        }
    }

    // MARK: - Private Methods

    private func startReachabilityObserver() {
        self.reachabilityManager?.startListening { status in
            if status == .notReachable {
                NotificationCenter.default.post(
                    name: Notification.Name("onReachabilityChanged"),
                    object: nil,
                    userInfo: ["isReachable": false]
                )
            } else if status == .reachable(.cellular) || status == .reachable(.ethernetOrWiFi) {
                NotificationCenter.default.post(
                    name: Notification.Name("onReachabilityChanged"),
                    object: nil,
                    userInfo: ["isReachable": true]
                )
            }
        }
    }

    private func removeReachabilityObserver() {
        self.reachabilityManager?.stopListening()
    }
}
