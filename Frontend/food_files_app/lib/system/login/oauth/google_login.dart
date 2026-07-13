import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogle(SupabaseClient supabase) async
{   
    const webClientId = '1045387728460-vfaekc3e8ulqd2rchdk6ff9aisnh700s.apps.googleusercontent.com';
    const iosClientId = '';
    
    final scopes = ['email', 'profile'];
    final googleSignIn = GoogleSignIn.instance;

    try
    {
        await googleSignIn.initialize
        (
            serverClientId: webClientId,
			clientId: iosClientId.isEmpty ? null : iosClientId,
        );

        // Bypass lightweight authentication to force a fresh UI interactive login prompt
        var googleUser = await googleSignIn.authenticate();

        final authorization =
            await googleUser.authorizationClient.authorizationForScopes(scopes) ??
            await googleUser.authorizationClient.authorizeScopes(scopes);

        final idToken = googleUser.authentication.idToken;
        if (idToken == null)
        {
            throw const AuthException('No ID Token found.');
        }

        await supabase.auth.signInWithIdToken
        (
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: authorization.accessToken,
        );

		final User? currentUser = supabase.auth.currentUser;
		print("=== SUPABASE LOGIN VERIFIED ===");
		print("User ID: ${currentUser?.id}");
		print("User Email: ${currentUser?.email}");
		print("Metadata: ${currentUser?.userMetadata}");
    }
    on Exception catch (error)
    {
		print("=== GOOGLE SIGN IN FAILURE DETECTED ===");
		print("Error Details: $error");
        rethrow;
    }
}