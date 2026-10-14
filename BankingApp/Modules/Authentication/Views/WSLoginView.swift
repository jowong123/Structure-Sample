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
    func viewDidSelectSshButton(_ view: WSLoginView)
    func viewDidSelectSaveBioButton(_ view: WSLoginView)
    func viewDidSelectUnlockButton(_ view: WSLoginView)
}

class WSLoginView: WSBaseView {

    // MARK: - Public UI elements

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log in"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    let signUpButton = WSLinkButton(
        title: "Sign up",
        prefix: "New to Wise?",
        alignment: .center,
        accessibilityIdentifier: LoginAccessibilityIdentifier.signUpButton.rawValue
    )

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

    let forgotPasswordButton = WSLinkButton(
        title: "Forgot password?",
        accessibilityIdentifier: LoginAccessibilityIdentifier.forgotPasswordButton.rawValue
    )

    let sshButton = WSLinkButton(
        title: "SSH Pinning Button?",
        accessibilityIdentifier: LoginAccessibilityIdentifier.sshButton.rawValue
    )

    let saveBioButton = WSLinkButton(
        title: "Save Bio Button?",
        accessibilityIdentifier: LoginAccessibilityIdentifier.saveBioButton.rawValue
    )

    let unlockBioButton = WSLinkButton(
        title: "Unlock Bio Button",
        accessibilityIdentifier: LoginAccessibilityIdentifier.unlockBioButton.rawValue
    )

    private let linkButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        return stack
    }()

    // MARK: Internal

    weak var delegate: WSLoginViewDelegate?

    // MARK: - Initializer

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .systemBackground

        // Password toggle inside the password field
        passwordTextField.rightView = togglePasswordVisibilityButton
        passwordTextField.rightViewMode = .always
        togglePasswordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        setupActions()

        [forgotPasswordButton, sshButton, saveBioButton, unlockBioButton].forEach {
            linkButtonsStack.addArrangedSubview($0)
        }

        [titleLabel, signUpButton, emailFieldLabel, emailTextField,
         passwordFieldLabel, passwordTextField, loginButton, linkButtonsStack].forEach {
            addSubview($0)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }

        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        emailFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }

        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailFieldLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }

        passwordFieldLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordFieldLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }

        togglePasswordVisibilityButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }

        linkButtonsStack.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupActions() {
        sshButton.onTap = { [weak self] in
            guard let self else { return }
            self.delegate?.viewDidSelectSshButton(self)
        }
        saveBioButton.onTap = { [weak self] in
            guard let self else { return }
            self.delegate?.viewDidSelectSaveBioButton(self)
        }
        unlockBioButton.onTap = { [weak self] in
            guard let self else { return }
            self.delegate?.viewDidSelectUnlockButton(self)
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
