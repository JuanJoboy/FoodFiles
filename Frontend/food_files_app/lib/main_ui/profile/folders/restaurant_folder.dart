import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
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

		return Expanded
		(
			child: list.restList.isNotEmpty ? ListView.builder
			(
				itemCount: list.restList.length,
				itemBuilder: (context, index)
				{
					return RestaurantFolderWidget(list.restList, index);
				},
			) : const Center(child: Text("No meals have been filed :(")) // If the list isn't empty then only print this text
		);
	}
}

class RestaurantFolder
{
	final String folderName;
	final List<LocationFolder> locationFolderList;

	RestaurantFolder(this.folderName, this.locationFolderList);
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
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		ColoredBox mainArea = ColoredBox // Defines the main content container.
		(
			color: Theme.of(context).brightness == Brightness.light ? colorScheme.surfaceContainerHighest : Colors.blueGrey, // Sets a subtle background color.
			child: const AnimatedSwitcher // Automatically cross-fades between pages when the page changes.
			(
				duration: Duration(milliseconds: 200),
				child: LocationFolderPage(),
			),
		);

		final String folderName = widget.list[widget.index].folderName;

		return Card
		(
			child: InkWell
			(
				onTap: ()
				{
					setState(()
					{
						Navigator.push
						(
							context,
							MaterialPageRoute(builder: (context) => mainArea),
						);
					});
    			},
				child: Padding
				(
      				padding: const EdgeInsets.all(16.0),
      				child: Text(folderName, textAlign: TextAlign.center,),
				),
  			),
		);
	}
}

class RestaurantFoldersList extends ChangeNotifier
{
	final List<RestaurantFolder> restList = List.empty(growable: true);
	final List<LocationFolder> locList = List.empty(growable: true);

	void createFolder(BuildContext context, RestaurantFolder restaurantFolder, LocationFolder locationFolder)
	{
		restList.insert(0, restaurantFolder);
		restaurantFolder.locationFolderList.insert(0, locationFolder);
		notifyListeners();

		final LocationFoldersList locationFoldersList = context.read<LocationFoldersList>(); // Cant do watch, have to do read. Watch rebuilds widgets, i just want to access data, not build any widgets in this area
		locationFoldersList.createFolder(locationFolder);
	}
}