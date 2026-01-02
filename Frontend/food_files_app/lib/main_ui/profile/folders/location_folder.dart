import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/profile/folders/filed_food.dart';
import 'package:provider/provider.dart';

class LocationFolderPage extends StatefulWidget
{
	const LocationFolderPage({super.key});

	@override
	State<LocationFolderPage> createState() => _LocationFolderPageState();
}

class _LocationFolderPageState extends State<LocationFolderPage>
{
	@override
	Widget build(BuildContext context)
	{
		final LocationFoldersList list = context.watch<LocationFoldersList>();

		return Expanded
		(
			child: list.foldersList.isNotEmpty ? ListView.builder
			(
				itemCount: list.foldersList.length,
				itemBuilder: (context, index)
				{
					return LocationFolderWidget(list.foldersList, index);
				},
			) : const Center(child: Text("No meals have been filed :(")) // If the list isn't empty then only print this text
		);
	}
}

class LocationFolder
{
	final String folderName;

	LocationFolder(this.folderName);
}

class LocationFolderWidget extends StatefulWidget
{
	final List<LocationFolder> list;
	final int index;
	const LocationFolderWidget(this.list, this.index, {super.key});

	@override
	State<LocationFolderWidget> createState() => _LocationFolderWidgetState();
}

class _LocationFolderWidgetState extends State<LocationFolderWidget>
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
				child: FiledFoodPage(),
			),
		);

		final String folderName = widget.list[widget.index].folderName;

		return Card
		(
			child: InkWell
			(
				onTap: ()
				{
					Navigator.push
					(
						context,
						MaterialPageRoute(builder: (context) => mainArea),
					);
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

class LocationFoldersList extends ChangeNotifier
{
	final List<LocationFolder> foldersList = List.empty(growable: true);

	void createFolder(LocationFolder folder)
	{
		foldersList.insert(0, folder);
		notifyListeners();
	}
}