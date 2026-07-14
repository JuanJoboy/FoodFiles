import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithFacebook(SupabaseClient supabase) async
{	
	await supabase.auth.signInWithOAuth
	(
		OAuthProvider.facebook,
		redirectTo: 'com.ichorlabs.foodfiles://login-callback', // Optionally set the redirect link to bring back the user via deeplink.
		authScreenLaunchMode: LaunchMode.platformDefault, // Launch the auth screen in a new webview on mobile.
	);
}