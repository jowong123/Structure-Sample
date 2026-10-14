//
//  Navigator.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

import Foundation
import UIKit

/**
 Base Navigator are protocol,
 exposing basic extensible with inheritance
 */

open class BaseNavigator: Navigator {
    open var rootViewController: WSNavigationController?
    open var currentViewController: UIViewController? {
        return self.rootViewController?.visibleViewController ?? self.rootViewController?.topViewController
    }

    public required init(with route: Route) {
        self.rootViewController = route.screen.embedInNavigationController()
    }
}

/**
 Base of this framework, handle all navigation stack,
 keep track current screen, and any navigation action
 */

public protocol Navigator: AnyObject {
    
    var rootViewController: WSNavigationController? { get set }

    var currentViewController: UIViewController? { get }

    init(with route: Route)
    
    /**
     Navigate from your current screen to a new route.:
     - route: The destination route of your navigation action.
     - transition: The transition type that you want to use.
     - animated: Animate the transition or not.
     - completion: Completion handler.
     */

    func navigate(
        to route: Route,
        with transition: TransitionType,
        animated: Bool,
        completion: (() -> Void)?
    )
    
    /**
     Navigate from your current screen to a new entire navigator.
     Can only push a router as a modal.
     Afterwards, other controllers can be pushed inside the presented Navigator.
     - Navigator: The destination navigator that you want to navigate to
     */

    func navigate(
        to router: Navigator,
        animated: Bool,
        completion: (() -> Void)?
    )
    
    func modalPop(animated: Bool)

    func dismiss(
        viewController: UIViewController?,
        animated: Bool,
        completion: (() -> Void)?
    )
}

extension Navigator {
    public func navigate(
        to route: Route,
        with transition: TransitionType,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let viewController = route.screen
        switch transition {
        case .modal(let presentedViewController):
            if let presentedViewController = presentedViewController {
                route.transitionConfigurator?(presentedViewController, viewController)
                presentedViewController.present(
                    viewController, animated: animated, completion: completion
                )
            } else {
                route.transitionConfigurator?(currentViewController, viewController)
                currentViewController?.present(
                    viewController, animated: animated, completion: completion
                )
            }
        case .modalPush(let navigationController):
            route.transitionConfigurator?(navigationController, viewController)
            navigationController.pushViewController(viewController, animated: animated)
        case .push:
            route.transitionConfigurator?(currentViewController, viewController)
            rootViewController?.pushViewController(viewController, animated: animated)
        case .reset:
            route.transitionConfigurator?(nil, viewController)
            rootViewController?.setViewControllers([viewController], animated: animated)
        case .changeRoot(let transitionType, let transitionSubtype):
            let navigationController = viewController.embedInNavigationController()
            self.animateRootReplacementTransition(
                to: navigationController,
                withTransitionType: transitionType,
                andTransitionSubtype: transitionSubtype
            )
            rootViewController = navigationController
        }
    }

    public func navigate(
        to router: Navigator,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let viewController = router.rootViewController else {
            assertionFailure("Navigator does not have a root view controller")
            return
        }

        currentViewController?.present(
            viewController, animated: animated, completion: completion
        )
    }

    public func modalPop(animated: Bool = true) {
        currentViewController?.navigationController?.popViewController(animated: animated)
    }

    public func pop(animated: Bool = true) {
        rootViewController?.popViewController(animated: animated)
    }

    public func popToRoot(animated: Bool = true) {
        rootViewController?.popToRootViewController(animated: animated)
    }

    public func dismiss(
        viewController: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        if let viewController = viewController {
            viewController.dismiss(animated: animated, completion: completion)
        } else {
            currentViewController?.dismiss(animated: animated, completion: completion)
        }
    }

    public func dismissAll(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        rootViewController?.dismiss(animated: animated, completion: completion)
    }

    private func animateRootReplacementTransition(
        to viewController: UIViewController,
        withTransitionType type: CATransitionType,
        andTransitionSubtype subtype: CATransitionSubtype
    ) {
        let window = AppDelegate.shared.getKeyWindow()
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeOut
        )
        transition.type = type
        transition.subtype = subtype
        window?.layer.add(transition, forKey: kCATransition)

        window?.rootViewController = viewController
    }
}

/**
 Protocol used to define a Route. The route contains
 all the information necessary to instantiate it's screen.
 For example, you have a LoginRoute, that knows how
 to instantiate it's viewModel, and also forward any
 information that it's passed to the Route.
 
 Basically sending data to anotherVC
 */

public protocol Route {
    typealias TransitionConfigurator = (_ sourceVc: UIViewController?, _ destinationVc: UIViewController) -> Void

    /// The screen that should be returned for that Route.
    var screen: UIViewController { get }

    /**
     Configuration callback executed just before pushing/presenting modally.
     Use this to set up any custom transition delegate, presentationStyle, etc.
     - Parameters:
     - sourceVc: The currently visible viewController, if any.
     - destinationVc: The (fully intialized) viewController to present.
     */
    var transitionConfigurator: TransitionConfigurator? { get }
}

extension Route {
    public var transitionConfigurator: TransitionConfigurator? {
        return nil
    }
}

public enum TransitionType {
    
    case modal(viewController: UIViewController? = nil)
    
    case modalPush(navigationController: UINavigationController)

    case push

    case reset

    case changeRoot(
        transitionType: CATransitionType,
        transitionSubtype: CATransitionSubtype
    )

    static let changeRoot: TransitionType = .changeRoot(
        transitionType: .push,
        transitionSubtype: .fromTop
    )
}

extension UIViewController {
    public func embedInNavigationController() -> WSNavigationController {
        if let navigationController = self as? WSNavigationController {
            return navigationController
        }
        let navigationController = WSNavigationController(rootViewController: self)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
}
