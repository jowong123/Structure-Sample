//
//  WSBaseView.swift
//  BankingApp
//
//  Created by jw on 20/04/2026.
//

import Foundation
import UIKit

class WSBaseView: UIView {
    
    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        self.setAccessibilityIdentifier()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        self.setAccessibilityIdentifier()
    }
    
    // MARK: - Private Methods
    
    private func setAccessibilityIdentifier() {
        let typeString = "\(type(of: self))"
        let components = typeString.components(separatedBy: ".")
        let identifier = components.last ?? "Unknown"
        self.accessibilityIdentifier = identifier
    }
    
    // MARK: - Internal Methods

    func updateView() {
        // Leave empty intentionally
    }
}
