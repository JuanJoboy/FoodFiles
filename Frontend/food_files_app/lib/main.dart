// import "package:english_words/english_words.dart"; // Imports a utility package containing thousands of common English words and functions to manipulate them. Used here to generate random WordPair objects.
import "package:flutter/material.dart"; // The core Flutter framework. It provides "Material Design" widgets (buttons, cards, scaffolds) and the engine for rendering the UI.
import "package:food_files_app/main_ui/feed/feed.dart";
// import "package:food_files_app/main_ui/post/post.dart";
import "package:food_files_app/main_ui/post/post2.dart";
import "package:food_files_app/main_ui/profile/folders/location_folder.dart";
import "package:food_files_app/main_ui/profile/profile.dart";
import "package:food_files_app/main_ui/profile/folders/restaurant_folder.dart";
import "package:food_files_app/utilities/colours.dart";
import "package:food_files_app/utilities/settings.dart";
import "package:food_files_app/utilities/utilities.dart";
import "package:provider/provider.dart"; // A state management package. It allows data (like the list of favorites) to be shared across different screens without manually passing it through every constructor.
// import 'package:google_fonts/google_fonts.dart';

void main()
{
	// Map Box and camera stuff
	WidgetsFlutterBinding.ensureInitialized();

	runApp
	(
		MultiProvider // Allows me to have multiple ChangeNotifiers
		(
			providers:
			[
				ChangeNotifierProvider(create: (context) => NavigationNotifier()),
				ChangeNotifierProvider(create: (context) => ProfileNavigationNotifier()),
				ChangeNotifierProvider(create: (context) => ThemeNotifier()),
				ChangeNotifierProvider(create: (context) => LocationFoldersList()), // A notifier that isn't dependent on anything, it's made first cause the one below needs it.
				ChangeNotifierProxyProvider<LocationFoldersList, RestaurantFoldersList> // The restaurant notifier is dependent on the location notifier. It gives the restaurant list a reference to the location list without having to pass around "context" and make it dependent on the UI tree
				(
					create: (_) => RestaurantFoldersList(), // Called once
					update: (_, locationList, restaurantList) // Called whenever the the dependency (location list) notifies listeners
					{
						restaurantList!.updateDependencies(locationList);
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
		const Color lightSeed = Color.fromARGB(255, 116, 187, 249);
		const Color darkSeed = Colors.blueGrey;
		
		return MaterialApp
		(
			title: 'Food Files',
			// Light Theme
			theme: ThemeData
			(
				textTheme: ThemeData.light().textTheme.apply
				(
					bodyColor: Colors.black,
					displayColor: Colors.black,
				),
				useMaterial3: true,
				scaffoldBackgroundColor: lightSeed,
				colorScheme: ColorScheme.fromSeed
				(
					brightness: Brightness.light,
					seedColor: lightSeed,
				),
				extensions: 
				[
					const AppColours
					(
						text: Colors.black,
						backgroundColour: lightSeed,
					)
				]
			),
			// Dark Theme
			darkTheme: ThemeData
			(
				textTheme: ThemeData.dark().textTheme.apply
				(
					bodyColor: Colors.white,
					displayColor: Colors.white,
				),
				useMaterial3: true,
				scaffoldBackgroundColor: darkSeed,
				colorScheme: ColorScheme.fromSeed
				(
					brightness: Brightness.dark,
					seedColor: darkSeed,
				),
				extensions: 
				[
					const AppColours
					(
						text: Colors.white,
						backgroundColour: darkSeed,
					)
				]
			),
			builder: (context, child)
			{
				// Makes the app look the same everywhere, and it won't adapt to people's phones settings
				return MediaQuery
				(
					data: MediaQuery.of(context).copyWith
					(
						textScaler: TextScaler.noScaling,
						boldText: false
					),
					child: child!
				);
			},
			themeMode: context.watch<ThemeNotifier>().currentUnit.value,
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
	@override
	Widget build(BuildContext context)
	{
		int selectedIndex = context.watch<NavigationNotifier>().selectedIndex;

		return LayoutBuilder
		(
			builder: (context, constraints)
			{
				return Scaffold // Use scaffold instead of column so that any space i missed out on isn't pure black. Scaffold works better on phones and has a dedicated nav bar parameter
				(
					body: AppBody(selectedIndex: selectedIndex), // put the main area above the mobile nav bar
					bottomNavigationBar: const MobileNavigationBar()
				);
			}
		);
	}
}

class AppBody extends StatelessWidget
{
	final int selectedIndex;

	const AppBody({super.key, required this.selectedIndex});

	@override
	Widget build(BuildContext context)
	{
		return SafeArea // Provides in built padding so that the app doesn't overlap the phone's OS items like time, battery, etc.
		(
			child: switch (selectedIndex)
			{
				0 => const PageSwitcher(nextPage: FeedPage()),
				// 1 => const PageSwitcher(nextPage: PostPage()), // Not in use at the moment
				// 1 => const PageSwitcher(nextPage: MapPage()),
				2 => const PageSwitcher(nextPage: ProfilePage()),
				_ => const PageSwitcher(nextPage: FeedPage()),
			}
		);
	}
}

class MobileNavigationBar extends StatelessWidget
{
	const MobileNavigationBar({super.key});

	@override
	Widget build(BuildContext context)
	{
		// Read the index so this micro-widget only rebuilds when the index changes
		final selectedIndex = context.read<NavigationNotifier>().selectedIndex;

		return BottomNavigationBar
		(
			type: BottomNavigationBarType.fixed,
			showSelectedLabels: false,
			showUnselectedLabels: false,
			currentIndex: selectedIndex,
			iconSize: 30,
			onTap: (value) => context.read<NavigationNotifier>().changeIndex(value),
			items:
			[
				_navItem(Icons.home_rounded, "Home"),
				_navItem(Icons.add, "Add", iconColour: Colors.green),
				_navItem(Icons.account_circle_rounded, "Profile"),
			],
		);
	}

	BottomNavigationBarItem _navItem(IconData icon, String label, {Color? iconColour})
	{
		return BottomNavigationBarItem
		(
			icon: Icon(icon, color: iconColour),
			label: label,
		);
	}
}

class NavigationNotifier extends ChangeNotifier
{
	int selectedIndex = 0;

	void changeIndex(int newIndex)
	{
		selectedIndex = newIndex;
		notifyListeners();
	}
}