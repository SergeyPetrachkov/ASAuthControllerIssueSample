//
//  AppleAuthenticator.swift
//  
//
//  Created by Sergey Petrachkov on 07/10/2021.
//

import Foundation
import AuthenticationServices

public final class AppleAuthenticator: NSObject {

    let anchor: UIWindow

    public init(anchor: UIWindow) {
        self.anchor = anchor
    }

    /// Do a stand-alone login with Apple.
    ///
    /// 1. Create ASAuthorizationAppleIDProvider request
    /// 2. Execute the request and continue with Apple
    public func login() {
        start()
    }

    public func login(with credential: ASAuthorizationAppleIDCredential) {
        guard let accessToken = credential.authorizationCode.flatMap({ String(data: $0, encoding: .utf8) }) else {
            return print("No token provided! Cannot go further! We need that auth code for our server to be able to validate user.")
        }
        print("Will login with apple id, passing \(accessToken) to our server, so it can fetch the necessary data.")
    }
}

private extension AppleAuthenticator {
    func start() {
        let appleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleIDRequest.requestedScopes = [.email, .fullName]

        let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AppleAuthenticator: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // MARK: - ASAuthorizationControllerDelegate

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            login(with: appleIDCredential)
        default:
            print("Irrelevant stuff")
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        anchor
    }
}
