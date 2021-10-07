//
//  EmailAuthenticator.swift
//  
//
//  Created by Sergey Petrachkov on 07/10/2021.
//

import Foundation
import AuthenticationServices

public final class EmailAuthenticator {
    public init() {}
    
    public func login(with credential: ASPasswordCredential) {
        print("Will login with \(credential.user) - \(credential.password)")
    }
}
