import 'package:flutter/material.dart';
import 'package:food_files_app/system/login/login_page.dart';
import 'package:food_files_app/system/login/non_oauth/non_auth_login.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatelessWidget
{
	const ResetPassword({super.key});

	@override
	Widget build(BuildContext context)
	{
        final double sidePadding = Utils.screenWidth(context) / 6;

		return SafeSpace
		(
			child: Padding
			(
				padding: EdgeInsets.symmetric(horizontal: sidePadding),
				child: Column
				(
					children: 
					[
						const Spacer(flex: 1),
						const Header(),
						const Spacer(flex: 1),

						EmailField(controller: context.read<PasswordResetNotifier>()._emailController),
						PasswordField(controller: context.read<PasswordResetNotifier>().password1Controller),
						PasswordField(controller: context.read<PasswordResetNotifier>().password2Controller),

						const Spacer(flex: 1),
						LoginButton
						(
							buttonFunctionality: () async => await context.read<PasswordResetNotifier>().next(context),
							buttonColor: Colors.blue,
							buttonText: "Next",
						),
						const Spacer(flex: 4),
					],
				),
			)
		);
	}
}

class Header extends StatelessWidget
{
	const Header({super.key});

	@override
	Widget build(BuildContext context)
	{
		return const Column
		(
			children:
			[
				Icon(Icons.key_rounded, size: 40),
				Text("Trouble With Logging In?"),
				Text("Change Your Password"),
				Text("Enter your email address and a new password below to change your password"),
			],
		);
	}
}

class PasswordResetNotifier extends ChangeNotifier
{
	// PRIVATE FIELDS
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _password1Controller = TextEditingController();
	final TextEditingController _password2Controller = TextEditingController();
	String _emailFieldMsg = "Email";
	bool _password1Visible = false;
	bool _password2Visible = false;

	// GETTERS
	TextEditingController get emailController => _emailController;
	TextEditingController get password1Controller => _password1Controller;
	TextEditingController get password2Controller => _password2Controller;
	String get emailFieldMsg => _emailFieldMsg;
	bool get password1Visible => _password1Visible;
	bool get password2Visible => _password2Visible;

	// SETTERS
	void setEmailFieldMsg(String emailFieldMsg)
	{
		_emailFieldMsg = emailFieldMsg;
		notifyListeners();
	}

	
	void setPassword1Visible(bool password1Visible)
	{
		_password1Visible = password1Visible;
		notifyListeners();
	}

	void setPassword2Visible(bool password2Visible)
	{
		_password2Visible = password2Visible;
		notifyListeners();
	}

	// FUNCTIONS
	@override
	void dispose()
	{
		_emailController.dispose();
		_password1Controller.dispose();
		_password2Controller.dispose();
		super.dispose();
	}

	void resetControllers()
	{
		_emailController.clear();
		_password1Controller.clear();
		_password2Controller.clear();
		notifyListeners();
	}

	bool areFieldsEmpty()
	{
		return (_emailController.text.trim().isEmpty) || (_password1Controller.text.trim().isEmpty) || (_password2Controller.text.trim().isEmpty);
	}

	Future<void> next(BuildContext context)
	{
		return Navigator.pushAndRemoveUntil
		(
			context,
			MaterialPageRoute(builder: (context) => const PageSwitcher(nextPage: LoginPage())),
			(Route<dynamic> route) => false,
		);
	}
}