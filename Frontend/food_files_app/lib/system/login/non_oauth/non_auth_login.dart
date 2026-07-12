import 'package:flutter/material.dart';
import 'package:food_files_app/system/login/login_page.dart';
import 'package:provider/provider.dart';

class NonOAuthLogin extends StatefulWidget
{
	const NonOAuthLogin({super.key});

	@override
	State<NonOAuthLogin> createState() => _NonOAuthLoginState();
}

class _NonOAuthLoginState extends State<NonOAuthLogin>
{
   	@override
	Widget build(BuildContext context)
	{
		return Column
		(
			children:
			[
				const EmailField(),
				const Padding(padding: EdgeInsetsGeometry.directional(top: 25)),
				const PasswordField(),

				const Padding(padding: EdgeInsetsGeometry.directional(top: 15)),
				const Row
				(
					mainAxisAlignment: MainAxisAlignment.end,
					children: 
					[
						BlueText(blueText: "Forgot Password?", signUpText: false)
					],
				),

				const Padding(padding: EdgeInsetsGeometry.directional(top: 25)),
				LoginButton
				(
					buttonFunctionality: () async
					{
						await context.read<LoginNotifier>().login(context);
					},
					buttonText: "Log In",
					buttonColor: Colors.blue
				),

				const Padding(padding: EdgeInsetsGeometry.directional(top: 25)),
				const BlueText(blueText: "Sign Up", signUpText: true)
			],
		);
	}
}

class EmailField extends StatelessWidget
{
	const EmailField({super.key});

	@override
	Widget build(BuildContext context)
	{
		return TextField
		(
			decoration: InputDecoration
			(
				border: const OutlineInputBorder(),
				enabledBorder: OutlineInputBorder
				(
					borderRadius: BorderRadius.circular(5)
				),
				hintText: "Email",
				filled: true,
			),
			controller: context.read<LoginNotifier>().emailController,
		);
	}
}

class PasswordField extends StatelessWidget
{
	const PasswordField({super.key});

	@override
	Widget build(BuildContext context)
	{
		final loginNotifier = context.read<LoginNotifier>();

		return TextField
		(
			decoration: InputDecoration
			(
				border: const OutlineInputBorder(),
				enabledBorder: OutlineInputBorder
				(
					borderRadius: BorderRadius.circular(5)
				),
				hintText: "Password",
				suffixIcon: IconButton
				(
					icon: Icon(loginNotifier.passwordVisible ? Icons.visibility : Icons.visibility_off),
					onPressed: ()
					{
						loginNotifier.setPasswordVisible(!loginNotifier.passwordVisible);
					},
				),
				filled: true,
			),
			controller: loginNotifier.passwordController,
			obscureText: !loginNotifier.passwordVisible,
			keyboardType: TextInputType.visiblePassword,
			textInputAction: TextInputAction.done,
		);
	}
}

class BlueText extends StatelessWidget
{
	final String blueText;
	final bool signUpText;

	const BlueText({super.key, required this.blueText, required this.signUpText});

	@override
	Widget build(BuildContext context)
	{
		return Text.rich
		(
			TextSpan
			(
				children:
				[
					TextSpan
					(
						text: signUpText ? "Don't have an account? " : "",
						style: const TextStyle
						(
							fontWeight: FontWeight.w500,
							fontSize: 15
						)
					),
					TextSpan
					(
						text: blueText,
						style: const TextStyle
						(
							color: Colors.blue,
							fontWeight: FontWeight.w900,
							fontSize: 18
						)
					)
				]
			)
		);
	}
}