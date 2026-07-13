import 'package:flutter/material.dart';
import 'package:food_files_app/system/login/login_page.dart';
import 'package:food_files_app/system/login/non_oauth/password_reset.dart';
import 'package:food_files_app/utilities/utilities.dart';
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
				const SizedBox(height: 16),
				const PasswordField(),
				const SizedBox(height: 8),

				Row
				(
					mainAxisAlignment: MainAxisAlignment.end,
					children: 
					[
						BlueText
						(
							nextPage: () => forgotPassword(),
							blueText: "Forgot Password?",
							signUpText: false
						)
					],
				),

				const SizedBox(height: 24),
				LoginButton
				(
					buttonFunctionality: () async => await login(),
					buttonColor: Colors.blue,
					buttonText: "Log In",
				),

				const SizedBox(height: 16),
				BlueText
				(
					nextPage: () => signUp(),
					blueText: "Sign Up",
					signUpText: true
				)
			],
		);
	}

	Future<void> login() async
	{

	}

	Future<void> forgotPassword()
	{
		return Navigator.push
		(
			context,
			MaterialPageRoute(builder: (context) => const PageSwitcher(nextPage: ResetPassword())),
		);
	}

	void signUp()
	{

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
				hintText: context.watch<LoginNotifier>().emailFieldMsg,
				hintStyle: const TextStyle(color: Colors.red),
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
	final Function() nextPage;
	final String blueText;
	final bool signUpText;

	const BlueText({super.key, required this.nextPage, required this.blueText, required this.signUpText});

	@override
	Widget build(BuildContext context)
	{
		return InkWell
		(
			onTap: () => nextPage(),
			child: Text.rich
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
			)
		);
	}
}