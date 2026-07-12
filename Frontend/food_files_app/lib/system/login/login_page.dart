import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_files_app/main.dart';
import 'package:food_files_app/system/login/non_oauth/non_auth_login.dart';
import 'package:food_files_app/system/login/oauth/auth_login.dart';
import 'package:food_files_app/utilities/utilities.dart';

class LoginPage extends StatefulWidget
{
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
	@override
	Widget build(BuildContext context)
	{
		final double sidePadding = Utils.screenWidth(context) / 6; // Gets the width of the screen and divides it by 6, then applies it as padding to the sides of the input fields

		return LayoutBuilder
		(
			builder: (context, constraints)
			{
				return Scaffold
				(
					body: SafeArea
					(
						child: Padding
						(
							padding: EdgeInsets.symmetric(horizontal: sidePadding),
							child: const Column
							(
								mainAxisSize: MainAxisSize.min,
								children:
								[
									Padding(padding: EdgeInsetsGeometry.directional(top: 50)),
									Header(),
									Padding(padding: EdgeInsetsGeometry.directional(bottom: 35)),

									OAuthLogin(),

									BreakLineText(),
									Padding(padding: EdgeInsetsGeometry.directional(bottom: 25)),

									NonOAuthLogin()
								],
							),
						)
					)
				);
			}
		);
	}
}

class Header extends StatelessWidget
{
	const Header({super.key});

	@override
	Widget build(BuildContext context)
	{
		return const FoodFilesTitle();
	}
}

class BreakLineText extends StatelessWidget
{
	const BreakLineText({super.key});

	@override
	Widget build(BuildContext context)
	{
		return const Row
		(
			children:
			[
				Expanded
				(
					child: Divider
					(
						thickness: 3,
						color: Colors.blueGrey,
					),
				),
				Padding
				(
					padding: EdgeInsets.symmetric(horizontal: 20.0),
					child: Text
					(
						"OR",
						style: TextStyle
						(
							color: Colors.blueGrey,
							fontWeight: FontWeight.bold,
							fontSize: 20
						),
					),
				),
				Expanded
				(
					child: Divider
					(
						thickness: 3,
						color: Colors.blueGrey,
					),
				),
			],
		);
	}
}

class LoginButton extends StatelessWidget
{
	final Future<void> Function() buttonFunctionality;
	final String? companyImage;
	final String buttonText;
	final Color buttonColor;

	const LoginButton({super.key, required this.buttonFunctionality, this.companyImage, required this.buttonText, required this.buttonColor});

	@override
	Widget build(BuildContext context)
	{
		return Row
		(
			children:
			[
				Expanded
				(
					child: Card
					(
						margin: EdgeInsets.zero, // Removes default Card margins if to get true full-width
						shape: RoundedRectangleBorder
						(
							borderRadius: BorderRadius.circular(5),
						),
						color: buttonColor,
						child: InkWell
						(
							onTap: buttonFunctionality,
							child: SizedBox
							(
								height: 40,
								child: ButtonHelper(buttonText: buttonText, companyImage: companyImage),
							),
						),
					),
				),
			],
		);
	}
}

class ButtonHelper extends StatelessWidget
{
	final String buttonText;
	final String? companyImage;

	const ButtonHelper({super.key, required this.buttonText, required this.companyImage});

	@override
	Widget build(BuildContext context)
	{
		if(buttonText == "Log In")
		{
			return Center
			(
				child: Text
				(
					buttonText, 
					style: const TextStyle
					(
						fontSize: 20,
						fontWeight: FontWeight.bold,
						color: Colors.white
					),
				)
			);
		}
		else
		{
			return Padding
			(
				padding: const EdgeInsets.symmetric(horizontal: 15.0), // Consistent indentation from button edge
				child: Row
				(
					mainAxisAlignment: MainAxisAlignment.start, // Aligns content to the left
					crossAxisAlignment: CrossAxisAlignment.center,
					children:
					[
						Image.asset
						(
							companyImage!,
							width: 24,
							height: 24,
							fit: BoxFit.cover,
						),

						const SizedBox(width: 16),

						Text
						(
							buttonText,
							style: const TextStyle
							(
								fontSize: 20,
								fontWeight: FontWeight.bold,
								color: Colors.white,
							),
						),
					],
				),
			);
		}
	}
}

class LoginNotifier extends ChangeNotifier
{
	// PRIVATE FIELDS
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	bool _passwordVisible = false;

	// GETTERS
	TextEditingController get emailController => _emailController;
	TextEditingController get passwordController => _passwordController;
	bool get passwordVisible => _passwordVisible;

	// SETTERS
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

	Future<void> login(BuildContext context)
	{
		return Navigator.pushAndRemoveUntil
		(
			context,
			MaterialPageRoute(builder: (context) => const PageSwitcher(nextPage: MyHomePage())),
			(Route<dynamic> route) => false,
		);
	}
}