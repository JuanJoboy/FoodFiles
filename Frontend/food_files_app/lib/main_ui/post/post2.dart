import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_files_app/main.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_search/mapbox_search.dart';

class Post
{
	// pfp
	final String restaurant;
	final String location;
	final DateTime date;
	final String postTitle;
	final String food;
	final String description;
	// image
	// final int likes = 0;
	// comment
	final double price;
	// final bool discounted = false;
	// final double originalPrice;
	final int rating;

	Post(this.restaurant, this.location, this.date, this.postTitle, this.food, this.description, this.price, this.rating);
}

class MapPage extends StatefulWidget
{
  	const MapPage({super.key});

	@override
	State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
{
	bool _permissionGranted = false;
	late geo.Position _userPosition;
	late MapboxMap _mapboxMap;
	String restaurant = "Unknown Restaurant";
	String location = "Unknown Location";

	static const String _key = String.fromEnvironment("ACCESS_TOKEN");
	GeoCodingApi _geoCoding = GeoCodingApi(apiKey: _key, limit: 1);
	
	Future<void> requestLocationPermission() async
	{
		PermissionStatus status = await Permission.location.status; // Gets the users current location permission status

		if(status.isDenied)
		{
			status = await Permission.location.request();
		}

		if(status.isGranted)
		{
			if(!mounted) // Because asynchronous tasks can finish after a user has already left the page (e.g., they hit the 'back' button while the popup was open), I check if the widget still exists before updating the UI.
			{
				return;
			}

			geo.Geolocator.getCurrentPosition().then((position)
			{
				if(mounted)
				{
					setState(() // Forces a rebuild of the ui and sets the permission
					{
						_permissionGranted = true;
						_userPosition = position;
						flyCameraTo(_userPosition.longitude, _userPosition.latitude);
					});
				}
			}); // Do the method call outside the setState so that i dont have to make it async, and also so that I can set the users position within the set state.
		}
		else if(status.isPermanentlyDenied)
		{
			openAppSettings(); // If the user ticked "never ask again," open settings
		}
	}

	@override
	void initState() // This is the standard place to start asynchronous tasks when a page loads. While initState itself is synchronous, it can call an async function. It will fire the request and then immediately move on to the build() method without waiting for the user to click "Allow."
	{
		super.initState();

		WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await requestLocationPermission());
	}

	@override
	Widget build(BuildContext context)
	{
		if(_permissionGranted)
		{
			return displayMapAndSearchBar(context, _userPosition.longitude, _userPosition.latitude);
		}
		else
		{
			return displayMapAndSearchBar(context, 0, 0);
		}
	}

	Widget displayMapAndSearchBar(BuildContext context, double longitude, double latitude)
	{
		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			body: Stack // I use stack instead of a column, so that the search bar is mixed with the map, like google maps. Instead of being in like separate sections
			(
				children:
				[
					map(context, longitude, latitude, restaurant, location), // Show the map
					searchBar(), // Show the search bar. This is called second and not first, because the map would cover it
				],
			)
		);
	}

	Widget searchBar()
	{
		return Padding
		(
			padding: const EdgeInsets.all(8),
			child: SearchAnchor
			(
				builder: (BuildContext context, SearchController controller)
				{
					return SearchBar
					(
						padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
						leading: const Icon(Icons.search), // leading places it at the start, trailing would place it at the end
						controller: controller,
						onTap: ()
						{
							// controller.openView();
						},
						onChanged: (_)
						{
							// controller.openView();
						},
						onSubmitted: (value)
						{
							// controller.closeView(value);
							getInfoFromSearch(value).then((info) => flyCameraTo(info.$1, info.$2));
						},
						onTapOutside: (event)
						{
							// controller.closeView(controller.text);
						},
					);
				},
				suggestionsBuilder: (BuildContext context, SearchController controller)
				{
					return List<ListTile>.generate(5, (int index)
					{
						final String item = 'item $index';
						return ListTile
						(
							title: Text(item),
							onTap: ()
							{
								setState(()
								{
									// controller.closeView(item);
								});
							},
						);
					});
				},
			),
        );
	}

	Widget map(BuildContext context, double longitude, double latitude, String restaurant, String location)
	{
		return MapWidget
		(
			onMapCreated: (mapController)
			{
				_mapboxMap = mapController;
				
				if(longitude == 0 && latitude == 0)
				{
					flyCameraTo(longitude, latitude, zoom: 2); // When the map is made, fly the camera to the users current location or 0, 0 if they denied location permissions
				}
				else
				{
					flyCameraTo(longitude, latitude);
				}
			},

			onTapListener: (mapContext) // Cant use async here since, the map engine triggers the tap event and moves on immediately to keep the map responsive (60fps). It doesn't want to "wait" for a network request to finish before allowing the user to zoom or scroll again.
			{
				double long = mapContext.point.coordinates.lng.toDouble();
				double lat = mapContext.point.coordinates.lat.toDouble();

				getInfoFromTap(long, lat).then((info) // Since the method isn't async, I use .then() to do the rest of the functionality
				{
					setState(()
					{
						restaurant = info.$1;
						location = info.$2;

						if(mounted) // Needed cause BuildContext doesn't like to go through between async methods
						{
							setState(()
							{
								Navigator.push
								(
									context,
									MaterialPageRoute(builder: (context) => Utils.switchPage(context, CalendarPage(restaurant, location))), // Also the method shouldn't be async, otherwise this method wouldn't play nice. And it should only happen after restaurant and location have actually been found. Otherwise it can move on when the async stuff hasn't finished yet
								);
							});
						}
					});
				});
			},
		);
	}

	Future<(double, double)> getInfoFromSearch(String search) async
	{
		dynamic response = await _geoCoding.getPlaces(search);
		
		double longitude = 0;
		double latitude = 0;

		if(response.success != null)
		{
			if(response.success!.isNotEmpty) // If tap was successful
			{
				MapBoxPlace place = response.success!.first; // Gets the first place in the list of places that was found from the search query

				// If the place was null, return 0 as the coordinates
				longitude = place.geometry?.coordinates.long ?? longitude;
				latitude = place.geometry?.coordinates.lat ?? latitude;
			}
		}

		return (longitude, latitude);
	}

	Future<(String, String)> getInfoFromTap(double longitude, double latitude) async
	{
		dynamic response = await _geoCoding.getAddress((long: longitude, lat: latitude));

		if(response.success != null)
		{
			if(response.success!.isNotEmpty) // If tap was successful
			{
				MapBoxPlace place = response.success!.first; // Get the place that was tapped on
				// If the place is somehow null, return unknown
				restaurant = place.text ?? restaurant;
				location = place.placeName ?? location;
			}
		}

		return (restaurant, location); // Return both strings together
	}

	void flyCameraTo(double longitude, double latitude, {double? zoom})
	{
		_mapboxMap.flyTo
		(
			CameraOptions
			(
				center: Point(coordinates: Position(longitude, latitude)),
				zoom: zoom ?? 12,
				bearing: 0,
				pitch: 0,
			),
			MapAnimationOptions
			(
				duration: 4000, // Already in milliseconds (1000 = 1 second)
				startDelay: 0
			)
		);
	}
}

class CalendarPage extends StatefulWidget
{
	final String restaurant;
	final String location;

	const CalendarPage(this.restaurant, this.location, {super.key});

	@override
	State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
{
	@override
  	Widget build(BuildContext context)
	{
		DateTime selectedDay = DateTime.now(); // The day that's actually selected

		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			appBar: AppBar(title: const Text("Calendar")),
			body: Padding
			(
				padding: const EdgeInsets.all(15.0),
				child: Column
				(
					children:
					[
						CalendarDatePicker
						(
							initialDate: DateTime.now(),
							firstDate: DateTime(1900),
							lastDate: DateTime(2100),
							onDateChanged: (DateTime day) => selectedDay = day
						),

						InkWell // This is a button
						(
							onTap: ()
							{
								setState(()
								{
									Navigator.push
									(
										context,
										MaterialPageRoute(builder: (context) => Utils.switchPage(context, DescriptionPage(widget.restaurant, widget.location, selectedDay))),
									);
								});
							},
							child: const Padding
							(
								padding: EdgeInsets.all(16.0),
								child: Text("Next", textAlign: TextAlign.center,),
							),
						),
					],
				)
			)
		);
  	}
}

class DescriptionPage extends StatefulWidget
{
	final String restaurant;
	final String location;
	final DateTime day;

  	const DescriptionPage(this.restaurant, this.location, this.day, {super.key});

	@override
	State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage>
{
	// The text field controllers, they need to be individual. If they shared each other then they'd have the same text
	final TextEditingController titleController = TextEditingController();
	final TextEditingController foodController = TextEditingController();
	final TextEditingController descriptionController = TextEditingController();
	final TextEditingController priceController = TextEditingController();
	final TextEditingController ratingController = TextEditingController();

	int? selectedRating = 5; // Just nice to auto place in the middle. And also i think its needed to set the actual rating

	List<DropdownMenuEntry<int>> ratingList = const [DropdownMenuEntry(value: 0, label: "0"), DropdownMenuEntry(value: 1, label: "1"), DropdownMenuEntry(value: 2, label: "2"), DropdownMenuEntry(value: 3, label: "3"), DropdownMenuEntry(value: 4, label: "4"), DropdownMenuEntry(value: 5, label: "5"), DropdownMenuEntry(value: 6, label: "6"), DropdownMenuEntry(value: 7, label: "7"), DropdownMenuEntry(value: 8, label: "8"), DropdownMenuEntry(value: 9, label: "9"), DropdownMenuEntry(value: 10, label: "10")]; // The list of numbers from 0 - 10

	late AllPosts _list;

	@override
	void dispose()
	{
		// Must be disposed to avoid memory leaks
		super.dispose();
		titleController.dispose();
		foodController.dispose();
		descriptionController.dispose();
		priceController.dispose();
		ratingController.dispose();
	}

	@override void initState()
	{
    	super.initState();
		final AllPosts list = context.read<AllPosts>(); // Since there's no context available here, I just read, rather than making and adding the widget to the tree
		_list = list; // Initializes the field

		// On the first go, it sets all the fields to blank, but then whenever the user goes to another page, and then back here, the page will rebuild with the previous values. This is so that the fields don't keep resetting
		titleController.text = _list.t;
		foodController.text = _list.f;
		descriptionController.text = _list.d;
		priceController.text = _list.p;
		ratingController.text = _list.r;
  	}

	@override
	Widget build(BuildContext context)
	{
		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displaySmall;

		bool fieldsAreEmpty = (titleController.text.trim() == "") || (foodController.text.trim() == "") || (descriptionController.text.trim() == "") || (priceController.text.trim() == "") || (ratingController.text.trim() == ""); // Ensures that all the fields are filled before a post can be posted

		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			appBar: AppBar(title: const Text("Description")),
			body: Padding
			(
				padding: const EdgeInsets.all(15.0),
				child: Column // try Stack
				(
					children:
					[
						// Restaurant
						immutableTextField("Restaurant", widget.restaurant, textStyle: textStyle),

						// Location
						immutableTextField("Location", widget.location, textStyle: textStyle),

						// Title
						textBox("Title", titleController, textStyle: textStyle, fieldToSave: 1),

						// Food
						textBox("Food", foodController, textStyle: textStyle, fieldToSave: 2),

						// Photo
						// uploadPhoto();

						// Description
						textBox("Description", descriptionController, textStyle: textStyle, fieldToSave: 3),

						// Price
						textBox("Price", priceController, textStyle: textStyle, fieldToSave: 4, priceField: true),

						// Rating
						ratingDropdown(),

						// Upload Button
						upload(fieldsAreEmpty),
					]
				)
			)
		);
  	}

	Widget immutableTextField(String fieldName, String text, {TextStyle? textStyle})
	{
		return Card
		(
			child: Column
			(
				children:
				[
					Text(fieldName, style: textStyle),
					Text(text, style: textStyle),
				],
			),
		);
	}

	Widget textBox(String fieldName, TextEditingController controller, {TextStyle? textStyle, bool? priceField, int? fieldToSave})
	{
		return Card
		(
			child: Column
			(
				children:
				[
					Text(fieldName, style: textStyle),

					TextField
					(
						style: textStyle,
						controller: controller,
						onChanged: (value)
						{
							setState(()
							{
								switch(fieldToSave)
								{
									case 1: _list.updateControllers(title: value);
									case 2: _list.updateControllers(food: value);
									case 3: _list.updateControllers(desc: value);
									case 4: _list.updateControllers(price: value);
								}
							});
						},
						inputFormatters: priceField == true ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))] : null
					),
				],
			),
		);
	}

	Widget ratingDropdown()
	{
		return DropdownMenu<int>
		(
			controller: ratingController,
			label: const Text('Rating'), // The mini label on the widget
			dropdownMenuEntries: ratingList, // The list from 0 - 10
			onSelected: (int? rating)
			{
				setState(()
				{
					selectedRating = rating;
					_list.updateControllers(rating: ratingController.text);
				});
			},
		);
	}

	Widget upload(bool fieldsAreEmpty)
	{
		return ElevatedButton
		(
			onPressed: fieldsAreEmpty ? null : () // if the fields are empty then grey out the button
			{
				_list.uploadPost(newPost(widget.restaurant, widget.location, widget.day, titleController, foodController, descriptionController, priceController, ratingController)); // If every field is filled in, upload the post

				setState(()
				{
					Navigator.popUntil(context, (route) => route.isFirst); // Goes back until it reaches the first page created (the home page)
				});
			},
			child: const Padding
			(
				padding: EdgeInsets.all(16.0),
				child: Text("Post", textAlign: TextAlign.center,),
			),
		);
	}

	// Im thinking like a big plus icon, but it should probably be sleeker and more compact
	// Below code shows an image, it does not open the camera roll
	// Widget uploadPhoto()
	// {
	// 	return Image.asset('assets/images/food.jpg');
	// }

	Post newPost(String restaurant, String location, DateTime calendar, TextEditingController title, TextEditingController food, TextEditingController description, TextEditingController price, TextEditingController rating)
	{
		// Trims and parses all the values so that everything is uploaded properly and without any excess
		Post post = Post(restaurant.trim(), location.trim(), calendar, title.text.trim(), food.text.trim(), description.text.trim(), double.parse(price.text.trim()), int.parse(rating.text.trim()));

		resetControllers(); // And make all the fields blank

		return post;
	}

	void resetControllers()
	{
		titleController.clear();
		foodController.clear();
		descriptionController.clear();
		priceController.clear();
		ratingController.clear();

		_list.updateControllers(title: titleController.text, food: foodController.text, desc: descriptionController.text, price: priceController.text, rating: ratingController.text);
	}
}

class AllPosts extends ChangeNotifier
{
	String t = "";
	String f = "";
	String d = "";
	String p = "";
	String r = "";

	void updateControllers({String? title, String? food, String? desc, String? price, String? rating})
	{
		// If the parameter isn't null, then save the value, so that when the page rebuilds, it rebuilds with this value
		if(title != null) t = title;
		if(food != null) f = food;
		if(desc != null) d = desc;
		if(price != null) p = price;
		if(rating != null) r = rating;

		notifyListeners();
	}

	final List<Post> postsList = List.empty(growable: true); // A master list that contains every post
	RestaurantFoldersList? _restaurantList; // The list that holds all the restaurant folders

	// This is called by ProxyProvider whenever RestaurantFoldersList changes
	void updateDependencies(RestaurantFoldersList list)
	{
		_restaurantList = list;
	}

	void uploadPost(Post post)
	{
		postsList.insert(0, post); // Adds the post to the list

		if(_restaurantList != null) // The list wont be null as this class is created last in the MultiProvider, but it's still good to check
		{
			makeFolders(_restaurantList, post.restaurant, post.location); // Whenever a post is uploaded, it either makes a restaurant folder, a location folder, or both. And then adds the post to the location folder that correlates to the location saved within the post
		}
		
		notifyListeners();
	}

	void makeFolders(RestaurantFoldersList? restaurantList, String restaurantName, String locationName)
	{
		// Checks if the restaurant folder already exists, and returns that folder
		RestaurantFolder restFolder = restaurantList!.restList
		.firstWhere
		(
			(folder) => folder.folderName.trim().toLowerCase() == restaurantName.trim().toLowerCase(), // Checks if it does exist
			orElse: () => RestaurantFolder(restaurantName, List.empty(growable: true)) // If it doesn't exist, makes a new restaurant folder with the name of the restaurant taken from the post, as well as a list of locations within the folder for the locations since it obviously doesn't exist yet
		);

		// If its a new restaurant folder, add it to the restaurant list and also add a new location folder object to the location list that was just made
		if(!restaurantList.restList.contains(restFolder))
		{
			restaurantList.createBothFolders(restFolder, LocationFolder(locationName));
		}
		else // Go through the location folders and do the same thing
		{
			// Checks if the location folder already exists
			LocationFolder locFolder = restFolder.locationFolderList
			.firstWhere
			(
				(folder) => folder.folderName.trim().toLowerCase() == locationName.trim().toLowerCase(),
				orElse: () => LocationFolder(locationName)
			);

			// If the location list inside the restaurant's folder doesn't contain the location folder that was just found then create a location folder
			if(!restFolder.locationFolderList.contains(locFolder))
			{
				restaurantList.createLocationFolder(restFolder, locFolder);
			}
		}
	}
}