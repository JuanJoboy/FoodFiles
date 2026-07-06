import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:mapbox_search/models/location.dart';
import 'package:sunrise_sunset_api/sunrise_sunset_api.dart';
// ignore: implementation_imports
import 'package:sunrise_sunset_api/src/sunrise_sunset_response.dart';

class MapNotifier extends ChangeNotifier
{
	// PRIVATE FIELDS
	bool _permissionGranted = false;
	geo.Position? _userPosition;
	MapboxMap? _mapboxMap;

	static const String _key = String.fromEnvironment("ACCESS_TOKEN");
	GeoCodingApi _geoCoding = GeoCodingApi(apiKey: _key, limit: null, types: [PlaceType.poi, PlaceType.place, PlaceType.neighborhood, PlaceType.address, PlaceType.locality]);

	// GETTERS
	bool get permissionGranted => _permissionGranted;
	geo.Position? get userPosition => _userPosition;
	MapboxMap? get mapboxMap => _mapboxMap;

	// SETTERS
	void setPermissionGranted(bool permissionGranted)
	{
		_permissionGranted = permissionGranted;
		notifyListeners();
	}

	void setUserPosition(geo.Position userPosition)
	{
		_userPosition = userPosition;
		notifyListeners();
	}

	void setMapboxMap(MapboxMap mapboxMap)
	{
		_mapboxMap = mapboxMap;
	}

	// FUNCTIONS
	void useMapboxKey()
	{
		MapboxOptions.setAccessToken(_key);
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
		
		_mapboxMap?.style.setStyleImportConfigProperty("basemap", "lightPreset", value);
	}

	Future<String> getInfoFromTap(double longitude, double latitude) async
	{
		var response = await _geoCoding.getAddress((long: longitude, lat: latitude));

		String location = "Unknown Location";

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

	Future<(double, double)> getInfoFromSearch(String search) async
	{
		var response = await _geoCoding.getPlaces(search, proximity: LocationProximity(loc: (lat: _userPosition?.latitude ?? 0, long: _userPosition?.longitude ?? 0)));
		
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

	void flyCameraTo(double longitude, double latitude, {double? zoom, int? duration})
	{
		_mapboxMap?.flyTo
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