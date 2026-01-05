// import "package:english_words/english_words.dart"; // Imports a utility package containing thousands of common English words and functions to manipulate them. Used here to generate random WordPair objects.
import "package:flutter/material.dart"; // The core Flutter framework. It provides "Material Design" widgets (buttons, cards, scaffolds) and the engine for rendering the UI.
import "package:food_files_app/main_ui/feed/feed.dart";
// import "package:food_files_app/main_ui/post/post.dart";
import "package:food_files_app/main_ui/post/post2.dart";
import "package:food_files_app/main_ui/profile/folders/location_folder.dart";
import "package:food_files_app/main_ui/profile/profile.dart";
import "package:food_files_app/main_ui/profile/folders/restaurant_folder.dart";
import "package:food_files_app/utilities/utilities.dart";
import "package:provider/provider.dart"; // A state management package. It allows data (like the list of favorites) to be shared across different screens without manually passing it through every constructor.
// import 'package:google_fonts/google_fonts.dart';

void main()
{
	// Map Box stuff
	WidgetsFlutterBinding.ensureInitialized();

	runApp
	(
		MultiProvider // Allows me to have multiple ChangeNotifiers
		(
			providers:
			[
				ChangeNotifierProvider(create: (context) => LocationFoldersList()), // A notifier that isn't dependent on anything, it's made first cause the one below needs it.
				ChangeNotifierProxyProvider<LocationFoldersList, RestaurantFoldersList> // The restaurant notifier is dependent on the location notifier. It gives the restaurant list a reference to the location list without having to pass around "context" and make it dependent on the UI tree
				(
					create: (_) => RestaurantFoldersList(), // Called once
					update: (_, locationList, restaurantList) // Called whenever the the dependency (location list) notifies listeners
					{
						restaurantList!.updateDependencies(locationList); // "!" (Null Assertion): Tells the Dart compiler that the object is definitely not null. If it is null, the app will throw a runtime error.
						return restaurantList;
					}
				),
				ChangeNotifierProxyProvider<RestaurantFoldersList, AllPosts>
				(
					create: (_) => AllPosts(),
					update: (_, restaurantList, allPosts)
					{
						allPosts!.updateDependencies(restaurantList);
						return allPosts;
					}
				),
			],
			child: const MyApp(), // The entire app now has access to a list of providers, rather than just creating and listening to 1
		)
	);
}

class MyApp extends StatelessWidget
{
	const MyApp({super.key});

	@override
	Widget build(BuildContext context)
	{
		const Color mySeed = Color.fromARGB(255, 0, 136, 255);
		
		return MaterialApp
		(
			title: 'Food Files',
			theme: ThemeData
			(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed
				(
					seedColor: mySeed,
					brightness: Brightness.light, // Light Mode
				),
			),
			darkTheme: ThemeData
			(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed
				(
					seedColor: mySeed,
					brightness: Brightness.dark, // Dark Mode
				),
			),
			themeMode: ThemeMode.system, // Auto sets to the device's setting
			home: const MyHomePage(), // The home page is immediately set to the feed because the index is set to 0 immediately
		);
	}
}

class MyHomePage extends StatefulWidget
{
	const MyHomePage({super.key});

	@override
	State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
	int selectedIndex = 0;

	@override
	Widget build(BuildContext context)
	{
		final ColoredBox mainArea = Utils.switchPage(context, getCurrentPage(selectedIndex));

		return LayoutBuilder
		(
			builder: (context, constraints)
			{
				final Device device = Utils.deviceIs(constraints);

				if(device == Device.phone)
				{
					return Scaffold // Use scaffold instead of column so that any space i missed out on isn't pure black. Scaffold works better on phones and has a dedicated nav bar parameter
					(
						body: mainArea, // put the main area above the mobile nav bar
						bottomNavigationBar: mobileNavigationBar()
					);
				}
				else // If the screen is wide, it returns a Row:
				{
					return Row
					(
						children: nonMobileNavigationBar(mainArea)
					);
				}
			}
		);
	}

	Widget getCurrentPage(int selectedIndex)
	{
		return switch(selectedIndex)
		{
			0 => const FeedPage(),
			// 1 => const PostPage(),
			1 => const MapPage(),
			2 => const ProfilePage(),
			_ => const FeedPage()
		};
	}

	Widget mobileNavigationBar()
	{
		return BottomNavigationBar
		(
			items:
			[
				BottomNavigationBarItem
				(
					icon: Transform.translate
					(
						offset: const Offset(0, 10), // Pushes the icon down 10 pixels
						child: const Icon(Icons.home_rounded, size: 30),
					),
					label: "" // Nav items need labels but I dont actually want any text
				),
				BottomNavigationBarItem
				(
					icon: Transform.translate
					(
						offset: const Offset(0, 10), // Pushes the icon down 10 pixels
						child: const Icon(Icons.add, size: 30, color: Colors.green,),
					),
					label: ""
				),
				BottomNavigationBarItem
				(
					icon: Transform.translate
					(
						offset: const Offset(0, 10),
						child: const Icon(Icons.account_circle_rounded, size: 30),
					),
					label: ""
				),
			],
			currentIndex: selectedIndex, // Sets the page to the feed page on start up
			onTap: (value) // When a tab is tapped, setState tells Flutter the selectedIndex changed, triggering a rebuild to show the new page.
			{
				setState( ()
				{
					selectedIndex = value; // Tapping on a nav bar item changes the page
				});
			},
		);
	}

	List<Widget> nonMobileNavigationBar(ColoredBox mainArea)
	{
		return
		[
			SafeArea
			(
				child: NavigationRail
				(
					// extended: constraints.maxWidth >= 600, // If the screen is very wide (600+), the side bar expands to show text labels next to the icons.
					destinations: const
					[
						NavigationRailDestination(icon: Icon(Icons.home, size: 50,), label: Text("")),
						NavigationRailDestination(icon: Icon(Icons.account_circle_rounded, size: 50,), label: Text("")),
					],
					selectedIndex: selectedIndex,
					onDestinationSelected: (value)
					{
						setState(()
						{
							selectedIndex = value;
						});
					},
				)
			),
			
			Expanded(child: mainArea), // The rest of the non-nav bar content takes up the remaining horizontal space to the right of the rail.
		];
	}
}