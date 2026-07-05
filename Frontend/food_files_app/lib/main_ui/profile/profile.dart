import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';

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
		// final Image profilePicture = ;
		final String accountName = "Juan";
		final int numberOfPosts = 3;
		final int followers = 30;
		final int following = 15;
		final String bio = "Cool guy";

		Brightness brightness = Theme.of(context).brightness;
		bool lightMode = brightness == Brightness.light;

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

				Switch
				(
					value: lightMode,
					onChanged: (value)
					{
						setState(()
						{
							lightMode = !value;

							if(brightness == Brightness.light)
							{
								brightness = Brightness.dark;
							}
							else
							{
								brightness = Brightness.light;
							}
						});
					},
					activeTrackColor: Colors.lightGreenAccent,
					activeThumbColor: Colors.green,
					inactiveTrackColor: Colors.redAccent,
					inactiveThumbColor: Colors.red,
				),

				profileTab(0, Icons.restaurant_menu), // Shows the posts in their folders
				profileTab(1, Icons.list_sharp), // Shows ... TODO: ADD MORE TABS

				Expanded
				(
					child: PageSwitcher(nextPage: getCurrentPage(selectedIndex)) // Shows the actual tab page below the profile details and tab buttons
				)
			],
		);
  	}

	// Tabs in the profile that transports the user to different sections such as the folder section, a custom list section, etc
	Widget profileTab(int index, IconData icon)
	{
		return ElevatedButton
		(
			onPressed: ()
			{
				setState(()
				{
					selectedIndex = index;
				});
			},
			child: Icon(icon)
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