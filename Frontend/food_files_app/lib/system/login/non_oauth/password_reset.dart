import 'package:flutter/material.dart';
import 'package:food_files_app/system/login/login_page.dart';
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

						EmailField(),
						PasswordField(),
						PasswordField2(),

						const Spacer(flex: 1),
						LoginButton
						(
							buttonFunctionality: () async => await next(context),
							buttonColor: Colors.blue,
							buttonText: "Next",
						),
						const Spacer(flex: 4),
					],
				),
			)
		);
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

class Header extends StatelessWidget
{
	const Header({super.key});

	@override
	Widget build(BuildContext context)
	{
		return Column
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

class PasswordField2 extends StatelessWidget
{
	const PasswordField2({super.key});

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