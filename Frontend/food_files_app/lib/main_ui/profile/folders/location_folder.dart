import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';

class LocationFolderPage extends StatefulWidget
{
	final RestaurantFolder restaurantFolder;
	const LocationFolderPage(this.restaurantFolder, {super.key});

	@override
	State<LocationFolderPage> createState() => _LocationFolderPageState();
}

class _LocationFolderPageState extends State<LocationFolderPage>
{
	@override
	Widget build(BuildContext context)
	{
		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			appBar: AppBar(title: const Text("Location Folders")), // Adds this text and a back button
			body: Column
			(
				children:
				[
					Expanded
					(
						child: widget.restaurantFolder.locationFolderList.isNotEmpty ? ListView.builder
						(
							itemCount: widget.restaurantFolder.locationFolderList.length,
							itemBuilder: (context, index)
							{
								return LocationFolderWidget(widget.restaurantFolder.locationFolderList, index, widget.restaurantFolder.folderName);
							},
						) : const Center(child: Text("No meals have been filed :(")),
					),
				],
			),
		);
	}
}

class LocationFolderWidget extends StatefulWidget
{
	final List<LocationFolder> list;
	final int index;
	final String restaurantName;
	const LocationFolderWidget(this.list, this.index, this.restaurantName, {super.key});

	@override
	State<LocationFolderWidget> createState() => _LocationFolderWidgetState();
}

class _LocationFolderWidgetState extends State<LocationFolderWidget>
{
	@override
	Widget build(BuildContext context)
	{
		final String restaurantName = widget.restaurantName;
		final String locationName = widget.list[widget.index].folderName;

		return Card
		(
			child: InkWell
			(
				onTap: ()
				{
					Navigator.push
					(
						context,
						MaterialPageRoute(builder: (context) => Utils.switchPage(context, FeedPage.filedMeals(restaurantName, locationName))), // Clicking on a location shows all the posts that are filtered by restaurant and location
					);
    			},
				child: Padding
				(
      				padding: const EdgeInsets.all(16.0),
      				child: Text(locationName, textAlign: TextAlign.center,),
				),
  			),
		);
	}
}

class LocationFolder
{
	final String folderName;

	LocationFolder(this.folderName);
}

class LocationFoldersList extends ChangeNotifier
{
	final List<LocationFolder> foldersList = List.empty(growable: true);

	void createFolder(LocationFolder folder)
	{
		foldersList.insert(0, folder); // Adds the location folder to the location list
		notifyListeners();
	}
}