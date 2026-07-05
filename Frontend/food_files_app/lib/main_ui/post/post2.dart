import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/models/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:sunrise_sunset_api/src/sunrise_sunset_response.dart';
import 'package:sunrise_sunset_api/sunrise_sunset_api.dart';

class Post
{
	// pfp
	final String restaurant;
	final String location;
	final DateTime date;
	final String postTitle;
	final String food;
	final String description;
	final String? image;
	// final int likes = 0;
	// comment
	final double price;
	// final bool discounted = false;
	// final double originalPrice;
	final double rating;

	Post(this.restaurant, this.location, this.date, this.postTitle, this.food, this.description, this.image, this.price, this.rating);
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
	GeoCodingApi _geoCoding = GeoCodingApi(apiKey: _key, limit: null, types: [PlaceType.poi, PlaceType.place, PlaceType.neighborhood, PlaceType.address, PlaceType.locality]);
	
	Future<void> requestLocationPermission() async
	{
		PermissionStatus status = await Permission.location.status; // Gets the users current location permission status

		if(status.isDenied)
		{
			status = await Permission.location.request();
		}

		if(status.isGranted)
		{
			_permissionGranted = true;

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
						_userPosition = position;

						updateMapLighting(_userPosition.longitude, _userPosition.latitude).then((_) => flyCameraTo(_userPosition.longitude, _userPosition.latitude));
					});
				}
			}); // Do the method call outside the setState so that i dont have to make it async, and also so that I can set the users position within the set state.
		}
		else if(status.isPermanentlyDenied)
		{
			openAppSettings(); // If the user ticked "never ask again," open settings
		}
	}

	Future<void> updateMapLighting(double longitude, double latitude) async
	{
		SunriseSunsetResponse? response = await SunriseSunset.getResults(date: DateTime.now(), latitude: latitude, longitude: longitude);

		String value = "dusk";

		if(response != null)
		{
			if(DateTime.now().isAfter(response.data!.civilTwilightBegin) && DateTime.now().isBefore(response.data!.sunrise))
			{
				value = "dawn";
			}
			else if(DateTime.now().isAfter(response.data!.sunrise) && DateTime.now().isBefore(response.data!.sunset))
			{
				value = "day";
			}
			else if(DateTime.now().isAfter(response.data!.sunset) && DateTime.now().isBefore(response.data!.civilTwilightEnd))
			{
				value = "dusk";
			}
			else
			{
				value = "night";
			}
		}
		
		_mapboxMap.style.setStyleImportConfigProperty("basemap", "lightPreset", value);
	}

	// TODO: Find a way to save the map permissions and state so that it doesnt build itself everytime you exit and go back to it
	@override
	void initState() // This is the standard place to start asynchronous tasks when a page loads. While initState itself is synchronous, it can call an async function. It will fire the request and then immediately move on to the build() method without waiting for the user to click "Allow."
	{
		super.initState();
		MapboxOptions.setAccessToken(_key);

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
							getInfoFromSearch(value).then((info) => flyCameraTo(info.$1, info.$2, zoom: 18));
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

			onStyleLoadedListener: (data)
			{
				_mapboxMap.style.setStyleImportConfigProperty("basemap", "lightPreset", "day");
				_mapboxMap.style.setStyleImportConfigProperty("basemap", "showPointOfInterestLabels", true);

				final poiIconTapInteraction = TapInteraction
				(
					FeaturesetDescriptor(featuresetId: "poi", importId: "basemap"), (poiIcon, tapContext)
					{
						// poiIcon features = {group: poi, class: food_and_drink, maki: restaurant, name: Took Bae Kee}
						restaurant = (poiIcon.properties["name"] ?? poiIcon.properties["name_en"] ?? restaurant) as String;

						final lng = tapContext.point.coordinates.lng.toDouble();
						final lat = tapContext.point.coordinates.lat.toDouble();
						flyCameraTo(lng, lat, zoom: 18, duration: 1000);

						getInfoFromTap(lng, lat).then((location) // Since the method isn't async, I use .then() to do the rest of the functionality
						{
							if(mounted) // Needed cause BuildContext doesn't like to go through between async methods
							{
								Navigator.push
								(
									context,
									MaterialPageRoute(builder: (context) => PageSwitcher(nextPage: CalendarPage(restaurant, location))) // Also the method shouldn't be async, otherwise this method wouldn't play nice. And it should only happen after restaurant and location have actually been found. Otherwise it can move on when the async stuff hasn't finished yet
								);
							}
						});
					}
				);

				_mapboxMap.addInteraction(poiIconTapInteraction);
			},
		);
	}

	Future<(double, double)> getInfoFromSearch(String search) async
	{
		var response = await _geoCoding.getPlaces(search, proximity: LocationProximity(loc: (lat: _userPosition.latitude, long: _userPosition.longitude)));
		
		double longitude = 0;
		double latitude = 0;

		if(response.success != null)
		{
			if(response.success!.isNotEmpty) // If tap was successful
			{
				MapBoxPlace place = response.success!.first; // Gets the first place in the list of places that was found from the search query

				print("""
					--- MAPBOX PLACE DATA ---
					ID: ${place.id}
					Text (Specific Name): ${place.text}
					Place Name (Full Address): ${place.placeName}
					Types: ${place.placeType}
					Address Number: ${place.addressNumber}
					Address/Street: ${place.address}
					Properties: ${place.properties?.toString()}
					Matching Text: ${place.matchingText}
					-------------------------
				""");

				// If the place was null, return 0 as the coordinates
				longitude = place.geometry?.coordinates.long ?? longitude;
				latitude = place.geometry?.coordinates.lat ?? latitude;
			}
		}

		return (longitude, latitude);
	}

	Future<String> getInfoFromTap(double longitude, double latitude) async
	{
		var response = await _geoCoding.getAddress((long: longitude, lat: latitude));

		if(response.success != null)
		{
			if(response.success!.isNotEmpty) // If tap was successful
			{
				MapBoxPlace place = response.success!.first; // Get the first result from the tap

				print("""
					--- MAPBOX PLACE DATA ---
					ID: ${place.id}
					Text (Specific Name): ${place.text}
					Place Name (Full Address): ${place.placeName}
					Types: ${place.placeType}
					Address Number: ${place.addressNumber}
					Address/Street: ${place.address}
					Properties: ${place.properties?.toString()}
					Matching Text: ${place.matchingText}
					-------------------------
				""");

				List<String> fullPlaceNameList = place.placeName!.split(","); // Gateways Shopping Centre North Access, Success Western Australia 6164, Australia
				String suburb = fullPlaceNameList[1]; // Splits it so that I just get Success Western Australia 6164
				location = suburb;
			}
		}

		return location;
	}

	void flyCameraTo(double longitude, double latitude, {double? zoom, int? duration})
	{
		_mapboxMap.flyTo
		(
			CameraOptions
			(
				center: Point(coordinates: Position(longitude, latitude)),
				zoom: zoom ?? 16,
				bearing: -0,
				pitch: 60,
			),
			MapAnimationOptions
			(
				duration: duration ?? 4000, // Already in milliseconds (1000 = 1 second)
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
								Navigator.push
								(
									context,
									MaterialPageRoute(builder: (context) => PageSwitcher(nextPage: DescriptionPage(widget.restaurant, widget.location, selectedDay)))
								);
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

	double? selectedRating = 5; // Just nice to auto place in the middle. And also i think its needed to set the actual rating

	List<DropdownMenuEntry<double>> ratingList = [for(int i = 0; i <= 100; i++) DropdownMenuEntry(value: i / 10, label: (i / 10).toStringAsFixed(1))]; // Ensures that i dont get any rounding weirdness like 4.99999

	String? imagePath = null;

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

		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			appBar: AppBar(title: const Text("Description")),
			body: SingleChildScrollView
			(
				child: Padding
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

							// Take Photo
							takePhoto(),

							// Display Photo
							displayPhoto(),

							// Description
							textBox("Description", descriptionController, textStyle: textStyle, fieldToSave: 3),

							// Price
							textBox("Price", priceController, textStyle: textStyle, fieldToSave: 4, priceField: true),

							// Rating
							ratingDropdown(),

							// Upload Button
							upload(),

							const SizedBox(height: 100)
						]
					)
				),
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
					Text(fieldName, style: textStyle?.copyWith(fontSize: 20)),
					Text(text, style: textStyle?.copyWith(fontSize: 20)),
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
					Text(fieldName, style: textStyle?.copyWith(fontSize: 20)),

					TextField
					(
						style: textStyle?.copyWith(fontSize: 20),
						controller: controller,
						onChanged: (value)
						{
							// setState() isn't needed here because it's straight up not needed when saving the controllers text, and in regards to the upload condition, the upload button is wrapped in a listenable that does the work for us
							switch(fieldToSave)
							{
								case 1: _list.updateControllers(title: value);
								case 2: _list.updateControllers(food: value);
								case 3: _list.updateControllers(desc: value);
								case 4: _list.updateControllers(price: value);
							}
						},
						inputFormatters: priceField == true ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))] : null
					),
				],
			),
		);
	}

	Widget takePhoto()
	{
		return InkWell
		(
			onTap: () async
			{
				final String? returnedPath = await Navigator.push
				(
					context,
					MaterialPageRoute(builder: (context) => const TakePictureScreen())
				);

				setState(()
				{
					imagePath = returnedPath;
				});
			},
			child: const Padding
			(
				padding: EdgeInsets.all(16.0),
				child: Icon(Icons.camera_alt_outlined)
			),
		);
	}

	Widget displayPhoto()
	{
		if(imagePath != null)
		{
			return Image.file
			(
				File(imagePath!),
				width: 200,
				height: 200,
				fit: BoxFit.cover,
				cacheWidth: 400, // Memory optimization
				errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
			);
		}
		else
		{
			return const Icon(Icons.local_pizza);
		}
	}

	Widget ratingDropdown()
	{
		return DropdownMenu<double>
		(
			controller: ratingController,
			label: const Text('Rating'), // The mini label on the widget
			dropdownMenuEntries: ratingList, // The list from 0 - 10
			onSelected: (double? rating)
			{
				selectedRating = rating;
				_list.updateControllers(rating: ratingController.text);
			},
		);
	}

	Widget upload()
	{
		return ListenableBuilder
		(
			listenable: Listenable.merge([titleController, foodController, descriptionController, priceController, ratingController]), // Combines all the controllers together to say "Track all these guys's changes"
			builder: (context, child)
			{
				return ElevatedButton
				(
					onPressed: areFieldsEmpty() ? null : () // if the fields are empty then grey out the button
					{
						_list.uploadPost(newPost(widget.restaurant, widget.location, widget.day, titleController, foodController, descriptionController, priceController, ratingController)); // If every field is filled in, upload the post

						Navigator.popUntil(context, (route) => route.isFirst); // Goes back until it reaches the first page created (the home page)
					},
					child: const Padding
					(
						padding: EdgeInsets.all(16.0),
						child: Text("Post", textAlign: TextAlign.center,),
					),
				);
			},
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
		Post post = Post(restaurant.trim(), location.trim(), calendar, title.text.trim(), food.text.trim(), description.text.trim(), imagePath?.trim(), double.parse(price.text.trim()), double.parse(rating.text.trim()));

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

	bool areFieldsEmpty()
	{
		return (titleController.text.trim().isEmpty) || (foodController.text.trim().isEmpty) || (descriptionController.text.trim().isEmpty) || (priceController.text.trim().isEmpty) || (ratingController.text.trim().isEmpty); // Ensures that all the fields are filled before a post can be posted
	}
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget
{
	const TakePictureScreen({super.key});

  	@override
  	TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
{
	late CameraController _controller;
	Future<void>? _initializeControllerFuture; // Instead of making it a late variable, just make it a nullable future<void> so that it can handle being null
	bool _permissionGranted = false;

	Future<void> requestCameraPermission() async
	{
		PermissionStatus status = await Permission.camera.status; // Gets the users current camera permission status
		final cameras = await availableCameras(); // Obtain a list of the available cameras on the device.
		
		if(status.isDenied)
		{
			status = await Permission.camera.request();
		}

		if(status.isGranted)
		{
			_permissionGranted = true;

			if(!mounted) // Because asynchronous tasks can finish after a user has already left the page (e.g., they hit the 'back' button while the popup was open), I check if the widget still exists before updating the UI.
			{
				return;
			}

			setState(() // Forces a rebuild of the ui and sets the permission
			{
				final firstCamera = cameras.first; // Get a specific camera from the list of available cameras.

				_controller = CameraController(firstCamera, ResolutionPreset.medium); // To display the current output from the Camera, create a CameraController.

				_initializeControllerFuture = _controller.initialize(); // Next, initialize the controller. This returns a Future.
			});
		}
		else if(status.isPermanentlyDenied)
		{
			openAppSettings(); // If the user ticked "never ask again," open settings
		}		
	}

	@override
	void initState()
	{
		super.initState();

		WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await requestCameraPermission());
	}

	@override
	void dispose()
	{
		if(_permissionGranted)
		{
			_controller.dispose();
		}

		super.dispose();
	}

  	@override
  	Widget build(BuildContext context)
	{
    	return Scaffold
		(
      		appBar: AppBar(title: const Text('Say Cheese')),

      		// You must wait until the controller is initialized before displaying the camera preview. Use a FutureBuilder to display a loading spinner until the controller has finished initializing.
			body: FutureBuilder<void>
			(
				future: _initializeControllerFuture,
				builder: (context, snapshot)
				{
					if (snapshot.connectionState == ConnectionState.done && _permissionGranted)
					{
						return CameraPreview(_controller); // If the Future is complete and permission has been granted, display the preview.
					}
					else
					{
						return const Center(child: CircularProgressIndicator()); // Otherwise, display a loading indicator.
					}
				},
			),
			
      		floatingActionButton: FloatingActionButton
			(
        		onPressed: () async
				{
          			try
					{
						await _initializeControllerFuture; // Ensure that the camera is initialized.

						final image = await _controller.takePicture(); // Attempt to take a picture and get the file `image` where it was saved.

						if (!context.mounted)
						{
							return;
						}

						// If the picture was taken, display it on a new screen.
						await Navigator.of(context).push
						(
							MaterialPageRoute
							(
								builder: (context) => DisplayPictureScreen(imagePath: image.path),
							),
						);
					}
					catch (e)
					{
						print(e); // If an error occurs, log the error to the console.
          			}
				},

				child: const Icon(Icons.camera_alt),
			),
		);
	}
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget
{
	final String imagePath;

	const DisplayPictureScreen({super.key, required this.imagePath});

	@override
	Widget build(BuildContext context)
	{
		return Scaffold
		(
			appBar: AppBar(),
			body: Column
			(
				children:
				[
					Image.file(File(imagePath)), // The image is stored as a file on the device. Use the `Image.file` constructor with the given path to display the image.

					InkWell
					(
						onTap: ()
						{
							Navigator.pop(context, imagePath);
							Navigator.pop(context, imagePath);
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