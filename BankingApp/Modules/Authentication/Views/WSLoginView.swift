//
//  WSLoginView.swift
//
//  Programmatic UIKit login view (no Storyboard/XIB needed).
//

import UIKit
import SnapKit

protocol WSLoginViewDelegate: AnyObject {
    var loginId: String { get set }
    var password: String { get set }
    var validationErrors: [WSLoginViewModel.ValidationError] { get }

    func viewDidSelectLoginButton(_ view: WSLoginView)
}

class WSLoginView: WSBaseView {
    
    // MARK: - Public UI elements (exposed so a VC can wire up targets/actions)
    // The code for UI is AI generated.

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log in"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor: UIColor.label,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let fullString = NSMutableAttributedString(string: "New to Wise? ", attributes: normalAttrs)
        fullString.append(NSAttributedString(string: "Sign up", attributes: boldAttrs))
        button.setAttributedTitle(fullString, for: .normal)
        button.accessibilityIdentifier = LoginAccessibilityIdentifier.signUpButton.rawValue
        return button
    }()

    let emailFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Your email address"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    let emailTextField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.setLeftPaddingPoints(14)
        field.setRightPaddingPoints(14)
        field.accessibilityIdentifier = LoginAccessibilityIdentifier.emailTextField.rawValue
        return field
    }()

    let passwordFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Your password"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    let passwordTextField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.setLeftPaddingPoints(14)
        field.accessibilityIdentifier = LoginAccessibilityIdentifier.passwordTextField.rawValue
        return field
    }()

    let togglePasswordVisibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .label
        button.accessibilityIdentifier = LoginAccessibilityIdentifier.togglePasswordButton.rawValue
        return button
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.68, green: 0.85, blue: 0.55, alpha: 1.0) // Wise-style green
        button.layer.cornerRadius = 27
        button.accessibilityIdentifier = LoginAccessibilityIdentifier.loginButton.rawValue
        return button
    }()

    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor: UIColor.label,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: "Forgot password?", attributes: attrs), for: .normal)
        button.contentHorizontalAlignment = .left
        button.accessibilityIdentifier = LoginAccessibilityIdentifier.forgotPasswordButton.rawValue
        return button
    }()

    // MARK: Internal

    weak var delegate: WSLoginViewDelegate?
    
    // MARK: - Initializer

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .systemBackground

        // Add password toggle button inside the password field
        passwordTextField.rightView = togglePasswordVisibilityButton
        passwordTextField.rightViewMode = .always
        togglePasswordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        [titleLabel, signUpButton, emailFieldLabel, emailTextField,
         passwordFieldLabel, passwordTextField, loginButton, forgotPasswordButton].forEach {
            addSubview($0)
        }

        // Title
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }

        // Sign up prompt
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // Email label
        emailFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }

        // Email field
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailFieldLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
        }

        // Password label
        passwordFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }

        // Password field
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordFieldLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
        }

        // Password toggle button size (inside rightView)
        togglePasswordVisibilityButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        // Login button
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
        }

        // Forgot password
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
    }

    // MARK: - Actions

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        togglePasswordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

// MARK: - UITextField padding helper

private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        rightView = paddingView
        rightViewMode = .always
    }
}
