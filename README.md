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
```
AppleAuthenticator(anchor: view.window!).login() // works
```

The only difference is that `AppleAuthenticator` uses only one request in `ASAuthorizationController`.

Any ideas, folks?
