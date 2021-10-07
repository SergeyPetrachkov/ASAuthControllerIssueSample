# ASAuthControllerIssueSample

So, here's the issue:

If I have both email-password and apple id records in my keychain for an app,
and want to request that data to do auto-login,
I can get email-password based accounts info fine.

Apple ID does not work as expected though.
I receive `ASAuthorizationAppleIDCredential` object with `authorizationCode == nil`. 
I do receive `credential.identityToken` and can decode the token. It's a valid one, but the thing is that I need `authorizationCode`.

If I use stand-alone `login` function of `AppleAuthenticator`, it works correctly. `ASAuthorizationController` executes `performRequests` perfectly and I can get `authorizationCode` from `ASAuthorizationAppleIDCredential`.
The issue is with `AggregatedAuthenticator`. It seems that `ASAuthorizationController` is sort of broken and cannot get all the data if there's more than one request passed to it.

```Swift
AggregatedAuthenticator(anchor: view.window!).startAutoLogin() // does not work with apple id
```

but

```Swift
AppleAuthenticator(anchor: view.window!).login() // works
```

The only difference is that `AppleAuthenticator` uses only one request in `ASAuthorizationController`.

The only workaround that I could come up with is if I go to `AggregatedAuthenticator` and do the login again there, see the comment in code:


```Swift
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
```

Any ideas, folks?
