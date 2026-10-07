//
//  WSLoginViewUITests.swift
//
//  UI tests for WSLoginView, using LoginAccessibilityIdentifier.
//  NOTE: LoginAccessibilityIdentifier must be visible to this UI test target.
//  Move it into its own file (e.g. LoginAccessibilityIdentifier.swift) and tick
//  both the app target and the UI test target under "Target Membership".
//

import XCTest

// MARK: - Placeholder identifiers for screens that don't exist yet
// These are sample identifiers for the Home, Sign Up and Forgot Password screens.
// When you build those screens, move these into the app (shared with this target)
// and assign them to the real views, the same way LoginAccessibilityIdentifier works.

private enum HomeAccessibilityIdentifier: String {
    case homeView = "home_view"
}

private enum SignUpAccessibilityIdentifier: String {
    case signUpView = "sign_up_view"
    case emailTextField = "sign_up_email_text_field"
}

private enum ForgotPasswordAccessibilityIdentifier: String {
    case forgotPasswordView = "forgot_password_view"
    case emailTextField = "forgot_password_email_text_field"
    case sendResetLinkButton = "forgot_password_send_button"
    case confirmationLabel = "forgot_password_confirmation_label"
}

final class WSLoginViewUITests: XCTestCase {

    private var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Optional: let the app know it's running under UI tests
        // (e.g. to reset state or start directly on the login screen).
        app.launchArguments += ["-UITesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Element accessors (Login)

    private var signUpButton: XCUIElement {
        app.buttons[LoginAccessibilityIdentifier.signUpButton.rawValue]
    }

    private var emailTextField: XCUIElement {
        app.textFields[LoginAccessibilityIdentifier.emailTextField.rawValue]
    }

    // isSecureTextEntry = true, so XCUITest exposes it as a *secure* text field.
    private var passwordTextField: XCUIElement {
        app.secureTextFields[LoginAccessibilityIdentifier.passwordTextField.rawValue]
    }

    private var loginButton: XCUIElement {
        app.buttons[LoginAccessibilityIdentifier.loginButton.rawValue]
    }

    private var forgotPasswordButton: XCUIElement {
        app.buttons[LoginAccessibilityIdentifier.forgotPasswordButton.rawValue]
    }

    // MARK: - Helpers

    private func type(_ text: String, into element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "\(element) not found")
        element.tap()
        element.typeText(text)
    }

    /// Waits until an element is no longer on screen (e.g. after navigating away).
    @discardableResult
    private func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Taps the back button in the navigation bar.
    private func tapBackButton() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 2), "Back button not found")
        backButton.tap()
    }

    // MARK: - Layout / existence

    func testLoginScreen_displaysAllElements() {
        XCTAssertTrue(emailTextField.waitForExistence(timeout: 5), "Login screen did not appear")

        XCTAssertTrue(signUpButton.exists)
        XCTAssertTrue(emailTextField.exists)
        XCTAssertTrue(passwordTextField.exists)
        XCTAssertTrue(loginButton.exists)
        XCTAssertTrue(forgotPasswordButton.exists)
    }

    func testLoginScreen_buttonsAreHittable() {
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))

        XCTAssertTrue(signUpButton.isHittable)
        XCTAssertTrue(loginButton.isHittable)
        XCTAssertTrue(forgotPasswordButton.isHittable)
    }

    // MARK: - Text input

    func testEmailField_showsKeyboardWhenTapped() {
        XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
        emailTextField.tap()

        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 2), "Keyboard did not appear")
    }

    func testEmailField_acceptsInput() {
        let email = "test@example.com"
        type(email, into: emailTextField)

        XCTAssertEqual(emailTextField.value as? String, email)
    }

    func testPasswordField_acceptsInputAndHidesIt() {
        let password = "Secret123"
        type(password, into: passwordTextField)

        let value = passwordTextField.value as? String ?? ""
        XCTAssertFalse(value.isEmpty, "Password field should contain text")
        XCTAssertNotEqual(value, password, "Password should be masked, not shown as plain text")
    }

    // MARK: - Actions

    func testLogin_withValidCredentials_redirectsToHome() {
        type("test@example.com", into: emailTextField)
        type("Secret123", into: passwordTextField)

        loginButton.tap()

        // Home screen should appear.
        let homeView = app.otherElements[HomeAccessibilityIdentifier.homeView.rawValue]
        XCTAssertTrue(homeView.waitForExistence(timeout: 5), "Home screen did not appear after login")

        // Login screen should be gone.
        XCTAssertTrue(waitForDisappearance(of: loginButton), "Login screen is still visible after login")
    }

    func testLogin_withEmptyFields() {
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))

        // Error label UI isn't built yet. Once it is, add an identifier for it, e.g.:
        // case emailErrorLabel = "email_error_label"
        //
        // let emailErrorLabel = app.staticTexts[LoginAccessibilityIdentifier.emailErrorLabel.rawValue]
        //
        // Error should be hidden before the user tries to log in.
        // XCTAssertFalse(emailErrorLabel.exists, "Error label should be hidden initially")

        loginButton.tap()

        // User should stay on the login screen.
        XCTAssertTrue(loginButton.exists)

        // Error should now be shown with the right message.
        // XCTAssertTrue(emailErrorLabel.waitForExistence(timeout: 2), "Error label should be shown")
        // XCTAssertEqual(emailErrorLabel.label, "Please enter your email address")
        //
        // Note: XCUITest can't read text color, so "red text" can't be checked here.
        // Verify the color in a unit test on the view, or with snapshot testing.
    }

    func testSignUpButton_tap_redirectsToSignUp() {
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 5))
        signUpButton.tap()

        // Sign up screen should appear.
        let signUpView = app.otherElements[SignUpAccessibilityIdentifier.signUpView.rawValue]
        XCTAssertTrue(signUpView.waitForExistence(timeout: 5), "Sign up screen did not appear")

        let signUpEmailField = app.textFields[SignUpAccessibilityIdentifier.emailTextField.rawValue]
        XCTAssertTrue(signUpEmailField.exists, "Sign up email field not found")

        // Going back should return to the login screen.
        tapBackButton()
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Did not return to login screen")
    }

    func testForgotPasswordButton_tap_redirectsToForgotPassword() {
        XCTAssertTrue(forgotPasswordButton.waitForExistence(timeout: 5))
        forgotPasswordButton.tap()

        // Forgot password screen should appear.
        let forgotPasswordView = app.otherElements[ForgotPasswordAccessibilityIdentifier.forgotPasswordView.rawValue]
        XCTAssertTrue(forgotPasswordView.waitForExistence(timeout: 5), "Forgot password screen did not appear")

        // Request a reset link.
        let resetEmailField = app.textFields[ForgotPasswordAccessibilityIdentifier.emailTextField.rawValue]
        type("test@example.com", into: resetEmailField)

        app.buttons[ForgotPasswordAccessibilityIdentifier.sendResetLinkButton.rawValue].tap()

        // A confirmation message should be shown.
        let confirmationLabel = app.staticTexts[ForgotPasswordAccessibilityIdentifier.confirmationLabel.rawValue]
        XCTAssertTrue(confirmationLabel.waitForExistence(timeout: 5), "Confirmation message did not appear")
    }
}
