//
//  WSLoginViewModelSpyTest.swift
//  BankingApp
//
//  Created by jw on 04/10/2026.
//

import XCTest
@testable import BankingApp

class myinMILoginViewModelSpyTests: XCTestCase {
    
    var viewModel: WSLoginViewModel!
    private var spyServices: AuthenticationSpyServices!
    
    
    private let validLoginId = "testing1@gmail.com"
    private let validPassword = "abcd1234AA++"
    
    // MARK: - Override Methods
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDown() {
        WSUserDataManager.shared.deleteTokens()

        self.viewModel = nil
        self.spyServices = nil

        super.tearDown()
    }
    
    // MARK: - Private Methods
    
    private func setupViewModel(
        loginId: String,
        password: String,
        isOtpSent: Bool = false,
        loginType: LoginType? = nil
    ) {
        spyServices = AuthenticationSpyServices(
            isOtpSent: isOtpSent,
            loginType: loginType
        )
        
        if self.viewModel != nil {
            self.viewModel = nil
        }
        self.viewModel = WSLoginViewModel(authenticationServices: spyServices)
        self.viewModel.loginId = loginId
        self.viewModel.password = password
    }
    
    private func performPostAuthenticate() -> NSError? {
        var receivedError: NSError?
        let exp = expectation(description: "Post Authenticate")

        self.viewModel.postAuthenticate(
            success: {
                exp.fulfill()
            },
            failure: { error in
                receivedError = error as NSError
                exp.fulfill()
            }
        )

        wait(for: [exp], timeout: 1)
        return receivedError
    }
   
    func test_postAuthenticate_sendsLowercasedLoginId() throws {
        self.setupViewModel(loginId: "Testing1@GMAIL.com", password: validPassword, loginType: .normal)

        // Act
        _ = self.performPostAuthenticate()

        XCTAssertEqual(self.spyServices.lastPostAuthenticateParams?["loginId"] as? String,
                       "testing1@gmail.com")
        
        self.setupViewModel(loginId: "Testing2@GMAIL.com", password: validPassword, loginType: .suspended)
        
        _ = self.performPostAuthenticate()
        
        XCTAssertEqual(self.spyServices.lastPostAuthenticateParams?["loginId"] as? String,
                       "testing2@gmail.com")
    }
    
    func test_postAuthenticate_invalidInput_doesNotCallService() throws {
        self.setupViewModel(loginId: "", password: "", loginType: .normal)
     
        let error = self.performPostAuthenticate()
     
        XCTAssertNotNil(error)
        XCTAssertEqual(self.spyServices.postAuthenticateCallCount, 0)
    }
}
