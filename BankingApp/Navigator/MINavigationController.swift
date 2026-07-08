//
//  MINavigationContrtoller.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import UIKit

public class WSNavigationController: UINavigationController {
    // MARK: - Properties
    // MARK: Override

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    // MARK: Private

    fileprivate var duringPushAnimation = false

    // MARK: - Initializer

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setup()
    }

    // MARK: - Lifecycle Events

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }

    // MARK: - Private Methods

    private func setup() {
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
        navigationItem.backBarButtonItem?.isEnabled = true
        navigationBar.prefersLargeTitles = false
    }

    // MARK: - Overrides Mehods

    override public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        self.duringPushAnimation = true

        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - UINavigationControllerDelegate

extension WSNavigationController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow _: UIViewController,
        animated _: Bool
    ) {
        guard let navigationController = navigationController as? WSNavigationController else {
            return
        }

        navigationController.duringPushAnimation = false
    }
}

// MARK: - UIGestureRecognizerDelegate

extension WSNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return false
        }
        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed

        return viewControllers.count > 1 && self.duringPushAnimation == false
    }
}

