import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/post/post.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
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
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		Widget page = getCurrentPage(selectedIndex);

		ColoredBox mainArea = ColoredBox // Defines the main content container.
		(
			color: Theme.of(context).brightness == Brightness.light ? colorScheme.surfaceContainerHighest : Colors.blueGrey, // Sets a subtle background color.
			child: AnimatedSwitcher // Automatically cross-fades between pages when the page changes.
			(
				duration: const Duration(milliseconds: 200),
				child: page,
			),
		);

		// final Image profilePicture = ;
		final String accountName = "Juan";
		final int numberOfPosts = 3;
		final int followers = 30;
		final int following = 15;
		final String bio = "Cool guy";

    	return Column
		(
			children:
			[
				const Icon(Icons.account_circle),
				Text(accountName),
				Text("Posts: $numberOfPosts"),
				Text("Followers: $followers"),
				Text("Following: $following"),
				Text(bio),

				ElevatedButton
				(
					onPressed: ()
					{
						setState(()
						{
							selectedIndex = 0;
						});
					},
					child: const Icon(Icons.restaurant_menu)
				),
				ElevatedButton
				(
					onPressed: ()
					{
						setState(()
						{
							selectedIndex = 1;
						});
					},
					child: const Icon(Icons.list_sharp)
				),
				Expanded
				(
					child: mainArea,
				)
			],
		);
  	}

	Widget getCurrentPage(int selectedIndex)
	{
		return switch(selectedIndex)
		{
			0 => const RestaurantFolderPage(),
			1 => const FeedPage(),
			_ => const RestaurantFolderPage()
		};
	}
}