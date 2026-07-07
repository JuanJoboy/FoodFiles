import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';

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