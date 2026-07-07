import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/post/components/post_calendar.dart';
import 'package:food_files_app/main_ui/post/map/map_controller.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget
{
  	const MapPage({super.key});

	@override
	State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
{
	Future<void> requestLocationPermission() async
	{
		MapNotifier mapNotifier = context.read<MapNotifier>();

		PermissionStatus status = await Permission.location.status; // Gets the users current location permission status

		if(status.isDenied)
		{
			status = await Permission.location.request();
		}

		if(status.isGranted)
		{
			if(mounted)
			{
				mapNotifier.setPermissionGranted(true);
			}

			if(!mounted) // Because asynchronous tasks can finish after a user has already left the page (e.g., they hit the 'back' button while the popup was open), I check if the widget still exists before updating the UI.
			{
				return;
			}

			geo.Geolocator.getCurrentPosition().then((userPosition)
			{
				if(mounted)
				{
					mapNotifier.setUserPosition(userPosition);

					geo.Position? position = mapNotifier.userPosition;

					if(position != null)
					{
						mapNotifier.updateMapLighting(position.longitude, position.latitude).then((_)
						{
							if(mounted)
							{
								mapNotifier.flyCameraTo(position.longitude, position.latitude);
							}
						});
					}
				}
			}); // Do the method call outside the setState so that i dont have to make it async, and also so that I can set the users position within the set state.
		}
		else if(status.isPermanentlyDenied)
		{
			openAppSettings(); // If the user ticked "never ask again," open settings
		}
	}

	// TODO: Find a way to save the map permissions and state so that it doesnt build itself everytime you exit and go back to it
	@override
	void initState() // This is the standard place to start asynchronous tasks when a page loads. While initState itself is synchronous, it can call an async function. It will fire the request and then immediately move on to the build() method without waiting for the user to click "Allow."
	{
		super.initState();

		WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await requestLocationPermission());
	}

	@override
	Widget build(BuildContext context)
	{
		geo.Position? userPosition = context.watch<MapNotifier>().userPosition;
		return DisplayMap(longitude: userPosition?.longitude ?? 0, latitude: userPosition?.latitude ?? 0);
	}
}

class DisplayMap extends StatelessWidget
{
	final double longitude;
	final double latitude;

	const DisplayMap({super.key, required this.longitude, required this.latitude});
		
	@override
	Widget build(BuildContext context)
	{
		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			body: Stack // I use stack instead of a column, so that the search bar is mixed with the map, like google maps. Instead of being in like separate sections
			(
				children:
				[
					Map(longitude: longitude, latitude: latitude), // Show the map
					const MapSearchBar(), // Show the search bar. This is called second and not first, because the map would cover it otherwise
				],
			)
		);
	}
}

class Map extends StatelessWidget
{
	final double longitude;
	final double latitude;

	const Map({super.key, required this.longitude, required this.latitude});
		
	@override
	Widget build(BuildContext context)
	{
		return MapWidget
		(
			onMapCreated: (mapController)
			{
				context.read<MapNotifier>().setMapboxMap(mapController);
				
				final livePosition = context.read<MapNotifier>().userPosition;
        
				if (livePosition == null)
				{
					context.read<MapNotifier>().flyCameraTo(0, 0, zoom: 2);
				}
				else
				{
					context.read<MapNotifier>().flyCameraTo(livePosition.longitude, livePosition.latitude);
				}
			},

			onStyleLoadedListener: (data)
			{
				final poiIconTapInteraction = TapInteraction
				(
					FeaturesetDescriptor(featuresetId: "poi", importId: "basemap"), (poiIcon, tapContext)
					{
						context.read<MapNotifier>().mapboxMap?.style.setStyleImportConfigProperty("basemap", "lightPreset", "day");
						context.read<MapNotifier>().mapboxMap?.style.setStyleImportConfigProperty("basemap", "showPointOfInterestLabels", true);

						// poiIcon features = {group: poi, class: food_and_drink, maki: restaurant, name: Took Bae Kee}
						final String restaurant = (poiIcon.properties["name"] ?? poiIcon.properties["name_en"] ?? "Unknown Restaurant") as String;

						final lng = tapContext.point.coordinates.lng.toDouble();
						final lat = tapContext.point.coordinates.lat.toDouble();
						context.read<MapNotifier>().flyCameraTo(lng, lat, zoom: 18, duration: 6000);

						context.read<MapNotifier>().getInfoFromTap(lng, lat).then((location) // Since the method isn't async, I use .then() to do the rest of the functionality
						{
							if(context.mounted)
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

				context.read<MapNotifier>().mapboxMap?.addInteraction(poiIconTapInteraction);
			},
		);
	}
}

class MapSearchBar extends StatelessWidget
{
	const MapSearchBar({super.key});
		
	@override
	Widget build(BuildContext context)
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
							context.read<MapNotifier>().getInfoFromSearch(value).then((info)
							{
								if(context.mounted)
								{
									context.read<MapNotifier>().flyCameraTo(info.$1, info.$2, zoom: 18);
								}
							});
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
								// controller.closeView(item);
							},
						);
					});
				},
			),
        );
	}
}