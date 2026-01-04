import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
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

	GeoCodingApi geoCoding = GeoCodingApi(limit: 1);
	
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

			geo.Position position = await geo.Geolocator.getCurrentPosition(); // Do the method call outside the setState so that i dont have to make it async, and also so that I can set the users position within the set state.
			setState(() // Forces a rebuild of the ui and sets the permission
			{
				_permissionGranted = true;
				_userPosition = position;
			});
			
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
			return displayMap(context, _userPosition.longitude, _userPosition.latitude);
		}
		else
		{
			return displayMap(context, 0, 0);
		}
	}

	Widget displayMap(BuildContext context, num longitude, num latitude)
	{
		final String restaurant = "";
		final String location = "";

		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			body: MapWidget
			(
				cameraOptions: CameraOptions
				(
					center: Point(coordinates: Position(longitude, latitude)),
					zoom: 2,
					bearing: 0,
					pitch: 0,
				),
				onTapListener: (mapContext) async
				{
					getInfoFromTap(mapContext.point.coordinates.lat.toDouble(), mapContext.point.coordinates.lng.toDouble());
					Utils.switchPage(context, CalendarPage(restaurant, location));
				},
				// Add a search bar, and make the camera fly to the location thats entered, for taps and searching. 
			)
		);
	}

	Future<(String?, String?)> getInfoFromTap(double latitude, double longitude) async
	{
		var response = await geoCoding.getAddress((lat: latitude, long: longitude));
		return getInfo(response);
	}

	Future<(String?, String?)> getInfoFromSearch(String search) async
	{
		var response = await geoCoding.getPlaces(search);
		return getInfo(response);
	}

	(String?, String?) getInfo(var response)
	{
		String? restaurant = "Unknown Restaurant";
		String? location = "Unknown Location";

		if(response.success!.isNotEmpty)
		{
			MapBoxPlace place = response.success!.first;	

			restaurant = place.text;
			location = place.placeName;
		}

		return (restaurant, location);
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

		return Padding
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
	@override
	Widget build(BuildContext context)
	{
		return Scaffold();
  	}
}

class PostPage extends StatefulWidget
{
  	const PostPage({super.key});

	@override
	State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
{
	// The text field controllers, they need to be individual. If they shared each other then they'd have the same text
	DateTime selectedDay = DateTime.now(); // The day that's actually selected
	DateTime focusedDay = DateTime.now(); // The slightly faded out marked day
	final TextEditingController restaurantController = TextEditingController();
	final TextEditingController locationController = TextEditingController();
	final TextEditingController foodController = TextEditingController();
	final TextEditingController descriptionController = TextEditingController();
	final TextEditingController priceController = TextEditingController();
	final TextEditingController ratingController = TextEditingController();

	int? selectedRating = 5; // Just nice to auto place in the middle. And also i think its needed to set the actual rating

	List<DropdownMenuEntry<int>> ratingList = const [DropdownMenuEntry(value: 0, label: "0"), DropdownMenuEntry(value: 1, label: "1"), DropdownMenuEntry(value: 2, label: "2"), DropdownMenuEntry(value: 3, label: "3"), DropdownMenuEntry(value: 4, label: "4"), DropdownMenuEntry(value: 5, label: "5"), DropdownMenuEntry(value: 6, label: "6"), DropdownMenuEntry(value: 7, label: "7"), DropdownMenuEntry(value: 8, label: "8"), DropdownMenuEntry(value: 9, label: "9"), DropdownMenuEntry(value: 10, label: "10")]; // The list of numbers from 0 - 10

	@override
	void dispose()
	{
		// Must be disposed to avoid memory leaks
		restaurantController.dispose();
		locationController.dispose();
		foodController.dispose();
		descriptionController.dispose();
		priceController.dispose();
		ratingController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context)
	{
		final AllPosts list = context.watch<AllPosts>();
		
		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displaySmall;
		bool fieldsAreEmpty = (restaurantController.text.trim() == "") || locationController.text.trim() == "" || (foodController.text.trim() == "") || (descriptionController.text.trim() == "") || (priceController.text.trim() == "") || (ratingController.text.trim() == ""); // Ensures that all the fields are filled before a post can be posted

		return Padding
		(
			padding: const EdgeInsets.only(top: 15.0),
			child: Column
			(
				children:
				[
					TableCalendar
					(
						firstDay: DateTime(1900),
						lastDay: DateTime(2100),
						focusedDay: focusedDay,
						availableCalendarFormats: const {CalendarFormat.week: "Week"}, // Makes this the only format allowed
						headerStyle: const HeaderStyle(formatButtonVisible: false), // Removes the button to change the format
						calendarFormat: CalendarFormat.week, // Makes the format only show the days in 1 week
						selectedDayPredicate:(day) => isSameDay(selectedDay, day), // Allows the day to actually be selected
						onDaySelected: (sDay, fDay)
						{
							setState(()
							{
								selectedDay = sDay;
								focusedDay = fDay;
							});
						},
						onPageChanged: (day)
						{
							setState(()
							{
								focusedDay = day;
							});
						},
					),
					Text("Restaurant", style: textStyle,),
					TextField(style: textStyle, controller: restaurantController),
					Text("Location", style: textStyle,),
					TextField(style: textStyle, controller: locationController),
					Text("Food", style: textStyle,),
					TextField(style: textStyle, controller: foodController),
					Text("Description", style: textStyle,),
					TextField(style: textStyle, controller: descriptionController),
					Text("Price", style: textStyle,),
					TextField(style: textStyle, controller: priceController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))]), // Only allows 2 decimal numbers
					Text("Rating", style: textStyle,),
					DropdownMenu<int>
					(
                        controller: ratingController,
                        label: const Text('Rating'), // The mini label on the widget
                        dropdownMenuEntries: ratingList, // The list from 0 - 10
                        onSelected: (int? rating)
						{
							setState(()
							{
								selectedRating = rating;
							});
                        },
					),

					ElevatedButton
					(
						onPressed: fieldsAreEmpty ? null : () // if the fields are empty then grey out the button
						{
							// list.uploadPost(newPost(selectedDay, restaurantController, locationController, foodController, descriptionController, priceController, ratingController)); // If every field is filled in, upload the post
							resetControllers(); // And make all the fields blank
						},
						child: const Text("Post")
					),
				],
			),
		);
  	}

	// Post newPost(DateTime calendar, TextEditingController restaurant, TextEditingController location, TextEditingController food, TextEditingController description, TextEditingController price, TextEditingController rating)
	// {
	// 	// Trims and parses all the values so that everything is uploaded properly and without any excess
	// 	Post post = Post(calendar, restaurant.text.trim(), location.text.trim(), food.text.trim(), description.text.trim(), double.parse(price.text.trim()), int.parse(rating.text.trim()));

	// 	return post;
	// }

	void resetControllers()
	{
		restaurantController.clear();
		locationController.clear();
		foodController.clear();
		descriptionController.clear();
		priceController.clear();
		ratingController.clear();
	}
}

class AllPosts extends ChangeNotifier
{
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