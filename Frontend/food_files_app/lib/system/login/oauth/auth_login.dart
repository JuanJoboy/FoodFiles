import 'package:flutter/material.dart';
import 'package:food_files_app/system/login/login_page.dart';
import 'package:food_files_app/system/login/oauth/apple_login.dart';
import 'package:food_files_app/system/login/oauth/facebook_login.dart';
import 'package:food_files_app/system/login/oauth/google_login.dart';
import 'package:food_files_app/system/login/oauth/microsoft_login.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthLogin extends StatefulWidget
{
	const OAuthLogin({super.key});

	@override
	State<OAuthLogin> createState() => _OAuthLoginState();
}

class _OAuthLoginState extends State<OAuthLogin>
{
	String? userId;
	final supabase = Supabase.instance.client;

	@override
	void initState()
	{
		super.initState();

		supabase.auth.onAuthStateChange.listen((data)
		{
			setState(()
			{
				userId = data.session?.user.id;
			});
		});
	}

	@override
	Widget build(BuildContext context)
	{
		return Column
		(
			children:
			[
				LoginButton
				(
					buttonFunctionality: () async
					{
						await signInWithGoogle(supabase);

						if(context.mounted)
						{
							context.read<LoginNotifier>().login(context);
						}
					},
					companyImage: 'assets/images/google-icon.png',
					buttonText: "Sign in with Google",
					buttonColor: Color(0xFFD9534F)
				),
				const Padding(padding: EdgeInsetsGeometry.directional(bottom: 25)),

				LoginButton
				(
					buttonFunctionality: () async
					{
						await signInWithApple(supabase);
						
						if(context.mounted)
						{
							context.read<LoginNotifier>().login(context);
						}
					},
					companyImage: 'assets/images/apple-icon.png',
					buttonText: "Sign in with Apple",
					buttonColor: Color(0xFF242426)
				),
				const Padding(padding: EdgeInsetsGeometry.directional(bottom: 25)),

				LoginButton
				(
					buttonFunctionality: () async
					{
						await signInWithFacebook(supabase);
						
						if(context.mounted)
						{
							context.read<LoginNotifier>().login(context);
						}
					},
					companyImage: 'assets/images/facebook-icon.png',
					buttonText: "Sign in with Facebook",
					buttonColor: Color(0xFF3B5998)
				),
				const Padding(padding: EdgeInsetsGeometry.directional(bottom: 25)),

				LoginButton
				(
					buttonFunctionality: () async
					{
						await signInWithMicrosoft(supabase);
						
						if(context.mounted)
						{
							context.read<LoginNotifier>().login(context);
						}
					},
					companyImage: 'assets/images/microsoft-icon.png',
					buttonText: "Sign in with Microsoft",
					buttonColor: Color(0xFF2F7470)
				),
			],
		);
	}
}