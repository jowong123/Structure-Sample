//
//  WSBaseViewControllerWithViewModel.swift
//  BankingApp
//
//  Created by jw on 07/07/2026.
//

class WSBaseViewControllerWithViewModel<T>: WSBaseViewController {
    // MARK: - Properties
    // MARK: Private

    private var _viewModel: T?

    // MARK: Internal

    var viewModel: T {
        get {
            guard let viewModel = _viewModel else {
                fatalError("View model not configured for \(type(of: self))")
            }
            return viewModel
        }

        set {
            self._viewModel = newValue
        }
    }
}
