import "package:english_words/english_words.dart"; // Imports a utility package containing thousands of common English words and functions to manipulate them. Used here to generate random WordPair objects.
import "package:flutter/material.dart"; // The core Flutter framework. It provides "Material Design" widgets (buttons, cards, scaffolds) and the engine for rendering the UI.
import "package:food_files_app/main_ui/feed/feed.dart";
import "package:food_files_app/main_ui/post/post.dart";
import "package:food_files_app/main_ui/profile/folders/location_folder.dart";
import "package:food_files_app/main_ui/profile/profile.dart";
import "package:food_files_app/main_ui/profile/folders/restaurant_folder.dart";
import "package:food_files_app/utilities/utilities.dart";
import "package:provider/provider.dart"; // A state management package. It allows data (like the list of favorites) to be shared across different screens without manually passing it through every constructor.
import 'package:google_fonts/google_fonts.dart';

void main()
{
	runApp
	(
		MultiProvider
		(
			providers:
			[
				ChangeNotifierProvider(create: (context) => AllPosts()),
				ChangeNotifierProvider(create: (context) => RestaurantFoldersList()),
				ChangeNotifierProvider(create: (context) => LocationFoldersList()),
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
					brightness: Brightness.light,
				),
			),
			darkTheme: ThemeData
			(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed
				(
					seedColor: mySeed,
					brightness: Brightness.dark,
				),
			),
			themeMode: ThemeMode.light,
			home: const MyHomePage(),
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
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		final Widget page = getCurrentPage(selectedIndex);

		ColoredBox mainArea = ColoredBox // Defines the main content container.
		(
			color: Theme.of(context).brightness == Brightness.light ? colorScheme.surfaceContainerHighest : Colors.blueGrey, // Sets a subtle background color.
			child: AnimatedSwitcher // Automatically cross-fades between pages when the page changes.
			(
				duration: const Duration(milliseconds: 200),
				child: page,
			),
		);

		return LayoutBuilder
		(
			builder: (context, constraints)
			{
				final Device device = Utils.deviceIs(constraints);

				if(device == Device.phone)
				{
					return Scaffold // Use scaffold instead of column so that any space i missed out on isnt pure black. Scaffold works better on phones and has a dedicated nav bar parameter
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
			1 => const PostPage(),
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
					label: ""
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
			currentIndex: selectedIndex,
			onTap: (value) // When a tab is tapped, setState tells Flutter the selectedIndex changed, triggering a rebuild to show the new page.
			{
				setState( ()
				{
					selectedIndex = value;
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