//
//  WSLinkButton.swift
//  BankingApp
//
//  Created by jw on 14/10/2026.
//

import UIKit

final class WSLinkButton: UIButton {

    // MARK: - Style

    struct Style {
        var titleFont: UIFont = .systemFont(ofSize: 15, weight: .bold)
        var titleColor: UIColor = .label
        var prefixFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
        var prefixColor: UIColor = .secondaryLabel
        var isUnderlined: Bool = true

        static let `default` = Style()
    }

    // MARK: - Public properties

    var title: String { didSet { updateAttributedTitle() } }
    var prefix: String? { didSet { updateAttributedTitle() } }
    var style: Style { didSet { updateAttributedTitle() } }

    /// Called on .touchUpInside. Use `[weak self]` when capturing an owner.
    var onTap: (() -> Void)?

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.5 : 1.0 }
    }

    // MARK: - Init

    init(
        title: String,
        prefix: String? = nil,
        style: Style = .default,
        alignment: UIControl.ContentHorizontalAlignment = .left,
        accessibilityIdentifier: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.prefix = prefix
        self.style = style
        self.onTap = onTap
        super.init(frame: .zero)

        contentHorizontalAlignment = alignment
        self.accessibilityIdentifier = accessibilityIdentifier
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        updateAttributedTitle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func updateAttributedTitle() {
        let result = NSMutableAttributedString()

        if let prefix, !prefix.isEmpty {
            result.append(NSAttributedString(string: prefix + " ", attributes: [
                .font: style.prefixFont,
                .foregroundColor: style.prefixColor
            ]))
        }

        var titleAttrs: [NSAttributedString.Key: Any] = [
            .font: style.titleFont,
            .foregroundColor: style.titleColor
        ]
        if style.isUnderlined {
            titleAttrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        result.append(NSAttributedString(string: title, attributes: titleAttrs))

        setAttributedTitle(result, for: .normal)
    }

    @objc private func handleTap() {
        onTap?()
    }
}
