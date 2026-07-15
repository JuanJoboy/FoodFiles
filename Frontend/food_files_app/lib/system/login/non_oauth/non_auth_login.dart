import 'package:flutter/material.dart';
import 'package:food_files_app/system/login/login_page.dart';
import 'package:food_files_app/system/login/non_oauth/password_reset.dart';
import 'package:food_files_app/system/login/non_oauth/sign_up.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:provider/provider.dart';

class NonOAuthLogin extends StatelessWidget
{
  	const NonOAuthLogin({super.key});

   	@override
	Widget build(BuildContext context)
	{
		final loginNotifier = context.read<LoginNotifier>();

		return Column
		(
			children:
			[
				EmailField(controller: loginNotifier.emailController),
				const SizedBox(height: 16),
				PasswordField(controller: loginNotifier.passwordController, passwordVisible: loginNotifier.passwordVisible, setPasswordVisible: (value) => loginNotifier.setPasswordVisible(!value)),
				const SizedBox(height: 8),

				Row
				(
					mainAxisAlignment: MainAxisAlignment.end,
					children: 
					[
						BlueText
						(
							nextPage: () async => await context.read<NonAuthNotifier>().forgotPassword(context),
							blueText: "Forgot Password?",
							signUpText: false
						)
					],
				),

				const SizedBox(height: 24),
				LoginButton
				(
					buttonFunctionality: () async => await context.read<LoginNotifier>().login(context),
					buttonColor: Colors.blue,
					buttonText: "Log In",
				),

				const SizedBox(height: 16),
				BlueText
				(
					nextPage: () async => await context.read<NonAuthNotifier>().signUp(context),
					blueText: "Sign Up",
					signUpText: true
				)
			],
		);
	}
}

class EmailField extends StatelessWidget
{
	final TextEditingController controller;

	const EmailField({super.key, required this.controller});

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
				hintStyle: TextStyle(color: context.read<LoginNotifier>().emailFieldMsg == "Email" ? Colors.black : Colors.red),
				filled: true,
			),
			controller: controller,
		);
	}
}

class PasswordField extends StatelessWidget
{
	final TextEditingController controller;
	final bool passwordVisible;
	final Function(bool) setPasswordVisible;

	const PasswordField({super.key, required this.controller, required this.passwordVisible, required this.setPasswordVisible});

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
				hintText: "Password",
				suffixIcon: IconButton
				(
					icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
					onPressed: ()
					{
						setPasswordVisible(passwordVisible);
					},
				),
				filled: true,
			),
			controller: controller,
			obscureText: passwordVisible,
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

class NonAuthNotifier extends ChangeNotifier
{
	// PRIVATE FIELDS
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	String _emailFieldMsg = "Email";
	bool _passwordVisible = false;

	// GETTERS
	TextEditingController get emailController => _emailController;
	TextEditingController get passwordController => _passwordController;
	String get emailFieldMsg => _emailFieldMsg;
	bool get passwordVisible => _passwordVisible;

	// SETTERS
	void setEmailFieldMsg(String emailFieldMsg)
	{
		_emailFieldMsg = emailFieldMsg;
		notifyListeners();
	}
	
	void setPasswordVisible(bool passwordVisible)
	{
		_passwordVisible = passwordVisible;
		notifyListeners();
	}

	// FUNCTIONS
	@override
	void dispose()
	{
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	void resetControllers()
	{
		_emailController.clear();
		_passwordController.clear();
		notifyListeners();
	}

	bool areFieldsEmpty()
	{
		return (_emailController.text.trim().isEmpty) || (_passwordController.text.trim().isEmpty);
	}

	Future<void> forgotPassword(BuildContext context)
	{
		return Navigator.push
		(
			context,
			MaterialPageRoute(builder: (context) => const PageSwitcher(nextPage: ResetPassword())),
		);
	}

	Future<void> signUp(BuildContext context)
	{
		return Navigator.push
		(
			context,
			MaterialPageRoute(builder: (context) => const PageSwitcher(nextPage: SignUp())),
		);
	}
}