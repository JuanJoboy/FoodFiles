import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:provider/provider.dart';

class RestaurantFolderPage extends StatefulWidget
{
	const RestaurantFolderPage({super.key});

	@override
	State<RestaurantFolderPage> createState() => _RestaurantFolderPageState();
}

class _RestaurantFolderPageState extends State<RestaurantFolderPage>
{
	@override
	Widget build(BuildContext context)
	{
		final RestaurantFoldersList list = context.watch<RestaurantFoldersList>();

		return Column
		(
			children:
			[
				Expanded
				(
					child: list.restList.isNotEmpty ? ListView.builder
					(
						itemCount: list.restList.length,
						itemBuilder: (context, index)
						{
							return RestaurantFolderWidget(list.restList, index); // Displays all the restaurant folders
						},
					) : const Center(child: Text("No meals have been filed :(")) // If the list isn't empty then only print this text
				)
			],
		);
	}
}

class RestaurantFolderWidget extends StatefulWidget
{
	final List<RestaurantFolder> list;
	final int index;
	const RestaurantFolderWidget(this.list, this.index, {super.key});

	@override
	State<RestaurantFolderWidget> createState() => _RestaurantFolderWidgetState();
}

class _RestaurantFolderWidgetState extends State<RestaurantFolderWidget>
{
	@override
	Widget build(BuildContext context)
	{
		ColoredBox mainArea = ColoredBox // Defines the main content container.
		(
			color: Utils.getBackgroundColor(Theme.of(context)), // Sets a subtle background color.
			child: AnimatedSwitcher // Automatically cross-fades between pages when the page changes.
			(
				duration: const Duration(milliseconds: 200),
				child: LocationFolderPage(widget.list[widget.index]), // Takes you to the page that shows all the locations connected to the restaurant
			),
		);

		final String folderName = widget.list[widget.index].folderName; // "widget" allows me to access the fields within the stateful widget above

		return Card
		(
			child: InkWell // This is a button
			(
				onTap: ()
				{
					setState(()
					{
						Navigator.push
						(
							context,
							MaterialPageRoute(builder: (context) => mainArea), // Takes you to the page that shows all the locations connected to the restaurant
						);
					});
    			},
				child: Padding
				(
      				padding: const EdgeInsets.all(16.0),
      				child: Text(folderName, textAlign: TextAlign.center,), // The name of the folder is the name of the restaurant
				),
  			),
		);
	}
}

class RestaurantFolder
{
	final String folderName;
	final List<LocationFolder> locationFolderList; // Every restaurant folder has a list of locations inside it

	RestaurantFolder(this.folderName, this.locationFolderList);
}

class RestaurantFoldersList extends ChangeNotifier
{
	final List<RestaurantFolder> restList = List.empty(growable: true);

	LocationFoldersList? _locationList; // Needs this list to track branch-specific data. When a lower-level list changes, the updateDependencies method ensures the parent has the most current reference.

	void updateDependencies(LocationFoldersList list)
	{
		_locationList = list;
	}

	void createBothFolders(RestaurantFolder restaurantFolder, LocationFolder locationFolder)
	{
		restList.insert(0, restaurantFolder); // Adds the folder that was freshly made to the restaurant list
		restaurantFolder.locationFolderList.insert(0, locationFolder); // Then adds the location folder to the location list within the restaurant list

		if(_locationList != null)
		{
			_locationList!.createFolder(locationFolder);
		}

		notifyListeners();
	}

	// Does the same thing as above, but just with the location folder if the restaurant folder already exists
	void createLocationFolder(RestaurantFolder restaurantFolder, LocationFolder locationFolder)
	{
		restaurantFolder.locationFolderList.insert(0, locationFolder);

		if(_locationList != null)
		{
			_locationList!.createFolder(locationFolder);
		}
		
		notifyListeners();
	}
}