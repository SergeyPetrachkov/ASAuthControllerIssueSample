//
//  AggregatedAuthenticator.swift
//
//
//  Created by Sergey Petrachkov on 07/10/2021.
//

import Foundation
import AuthenticationServices

public final class AggregatedAuthenticator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let anchor: UIWindow

    private lazy var appleAuthenticator = AppleAuthenticator(anchor: anchor)
    private lazy var emailAuthenticator = EmailAuthenticator()

    public init(anchor: UIWindow) {
        self.anchor = anchor
    }

    /// Autologin feature.
    ///
    /// 1. Request ASAuthorizationController to retrieve all existing accounts (email-password combo and/or apple sign-ups).
    /// 2. Then user should choose a way to log in
    /// 3. And we pass execution to concrete auth implementaions
    public func startAutoLogin() {
        let appleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleIDRequest.requestedScopes = [.email, .fullName]

        let emailProvider = ASAuthorizationPasswordProvider()
        let emailRequest = emailProvider.createRequest()

        let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest, emailRequest])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }


    // MARK: - ASAuthorizationControllerDelegate

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Question: here we receive the credential without authorizationCode, but why?
            appleAuthenticator.login(with: appleIDCredential)
            // BUT if I do:
            // appleAuthenticator.login()
            // it works fine, but it shows that bottom sheet again asking for your face/touch-id again, but only for apple id this time
        case let emailPasswordPair as ASPasswordCredential:
            emailAuthenticator.login(with: emailPasswordPair)
        default:
            print("Irrelevant stuff")
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let authError = error as? ASAuthorizationError else {
            return print(error)
        }
        switch authError.code {
        case .canceled:
            print("User cancelled the whole thing")
        default:
            print("Other auth error: \(authError)")
        }
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        anchor
    }
}
