import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/settings.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:provider/provider.dart';

class Profile
{
	final Image profilePicture;
	final String accountName;
	final int numberOfPosts;
	final int followers;
	final int following;
	final String bio;

	Profile(this.profilePicture, this.accountName, this.numberOfPosts, this.followers, this.following, this.bio);
}

class ProfilePage extends StatefulWidget
{
  	const ProfilePage({super.key});

	@override
	State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
{
	int selectedIndex = 0;

	@override
	Widget build(BuildContext context)
	{
		int selectedIndex = context.watch<ProfileNavigationNotifier>().selectedIndex;

		final String profilePicture = "/Frontend/food_files_app/assets/images/pfp.jpg";
		final String accountName = "Juan";
		final int numberOfPosts = 3;
		final int followers = 30;
		final int following = 15;
		final String bio = "Cool guy";

    	return Column
		(
			children:
			[
				Image.file
				(
					File(profilePicture),
					cacheWidth: 400, // Memory optimization
					errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle),
				),

				Text(accountName),
				Text("Posts: $numberOfPosts"),
				Text("Followers: $followers"),
				Text("Following: $following"),
				Text(bio),

				ListTile(trailing: const DarkModeSwitch(), title: Text(Utils.whatModeIsIt(context.watch<ThemeNotifier>().isBaseMode, ThemeSetting.darkMode.name, ThemeSetting.lightMode.name))),

				const ProfileNavigationBar(),

				Expanded
				(
					child: ProfileGallery(selectedIndex: selectedIndex)
				)
			],
		);
  	}
}

class ProfileGallery extends StatelessWidget
{
	final int selectedIndex;

	const ProfileGallery({super.key, required this.selectedIndex});

	@override
	Widget build(BuildContext context)
	{
		return switch (selectedIndex)
		{
			0 => const PageSwitcher(nextPage: RestaurantFolderPage()),
			1 => const PageSwitcher(nextPage: FeedPage()),
			2 => const PageSwitcher(nextPage: RestaurantFolderPage()),
			_ => const PageSwitcher(nextPage: RestaurantFolderPage()),
		};
	}
}

class ProfileNavigationBar extends StatelessWidget
{
	const ProfileNavigationBar({super.key});

	@override
	Widget build(BuildContext context)
	{
		return Row
		(
			crossAxisAlignment: CrossAxisAlignment.center,
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children:
			[
				ProfileGalleryItem(icon: Icons.restaurant_menu_rounded, label: "Restaurants", context: context, index: 0),
				ProfileGalleryItem(icon: Icons.home, label: "XXX", context: context, index: 1),
				ProfileGalleryItem(icon: Icons.report_sharp, label: "YYY", context: context, index: 2),
			],
		);
	}
}

class ProfileGalleryItem extends StatelessWidget
{
	final IconData icon;
	final String label;
	final BuildContext context;
	final int index;

	const ProfileGalleryItem({super.key, required this.icon, required this.label, required this.context, required this.index});

	@override
	Widget build(BuildContext context)
	{
		bool itemSelected = context.watch<ProfileNavigationNotifier>().selectedIndex == index;

		return ElevatedButton
		(
			onPressed: ()
			{
				context.read<ProfileNavigationNotifier>().changeIndex(index);
			},
			child: Icon
			(
				icon,
				semanticLabel: label,
				size: itemSelected == true ? 32 : 24,
				weight: itemSelected == true ? 600 : 400,
				grade: itemSelected == true ? 100 : 50,
			)
		);
	}
}

class ProfileNavigationNotifier extends ChangeNotifier
{
	int selectedIndex = 0;

	void changeIndex(int newIndex)
	{
		selectedIndex = newIndex;
		notifyListeners();
	}
}