import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogle(SupabaseClient supabase) async
{	
	// Use your Local Dev Web Client ID here
	const webClientId = '1045387728460-vfaekc3e8ulqd2rchdk6ff9aisnh700s.apps.googleusercontent.com';
	
	// Leave empty for Android testing, or add your Google Console iOS ID if testing iOS
	const iosClientId = ''; 
	
	final scopes = ['email', 'profile'];
	final googleSignIn = GoogleSignIn.instance;

	// Initialize utilizing the new v7.x format
	await googleSignIn.initialize
	(
		serverClientId: webClientId,
		clientId: iosClientId.isEmpty ? null : iosClientId,
	);

	// Attempt silent login first
	var googleUser = await googleSignIn.attemptLightweightAuthentication();
	
	// Fallback to explicit authentication if needed
	if (googleUser == null && googleSignIn.supportsAuthenticate())
	{
		googleUser = await googleSignIn.authenticate();
	}

	// TODO: Make sure that all errors are handled, for example, not signing in, and going backwards when on the part that shows the google accounts, shouldn't cause an error

	if (googleUser == null)
	{
		throw const AuthException('Failed to sign in with Google.');
	}

	// Authorize scopes using the new v7.x ClientAuthorization model
	final authorization =
		await googleUser.authorizationClient.authorizationForScopes(scopes) ??
		await googleUser.authorizationClient.authorizeScopes(scopes);

	final idToken = googleUser.authentication.idToken;
	if (idToken == null)
	{
		throw const AuthException('No ID Token found.');
	}

	// Pass tokens straight to your local Supabase instance
	await supabase.auth.signInWithIdToken
	(
		provider: OAuthProvider.google,
		idToken: idToken,
		accessToken: authorization.accessToken,
	);
}