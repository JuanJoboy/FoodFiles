import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_files_app/main_ui/feed/feed.dart';
import 'package:food_files_app/main_ui/profile/folders/location_folder.dart';
import 'package:food_files_app/main_ui/profile/profile.dart';
import 'package:food_files_app/main_ui/profile/folders/restaurant_folder.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Post
{
	final String restaurant;
	// pfp
	final String location;
	final String food;
	final String description;
	// image
	// final int likes = 0;
	// comment
	final double price;
	// final bool discounted = false;
	// final double originalPrice;
	final int rating;

	Post(this.restaurant, this.location, this.food, this.description, this.price, this.rating);
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
	final TextEditingController restaurantController = TextEditingController();
	final TextEditingController locationController = TextEditingController();
	final TextEditingController foodController = TextEditingController();
	final TextEditingController descriptionController = TextEditingController();
	final TextEditingController priceController = TextEditingController();
	final TextEditingController ratingController = TextEditingController();

	int? selectedRating = 5; // Just nice to auto place in the middle. And also i think its needed to set the actual rating

	List<DropdownMenuEntry<int>> ratingList = const [DropdownMenuEntry(value: 1, label: "1"), DropdownMenuEntry(value: 2, label: "2"), DropdownMenuEntry(value: 3, label: "3"), DropdownMenuEntry(value: 4, label: "4"), DropdownMenuEntry(value: 5, label: "5"), DropdownMenuEntry(value: 6, label: "6"), DropdownMenuEntry(value: 7, label: "7"), DropdownMenuEntry(value: 8, label: "8"), DropdownMenuEntry(value: 9, label: "9"), DropdownMenuEntry(value: 10, label: "10")]; // The list of numbers from 1 - 10

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
		bool fieldsAreEmpty = (restaurantController.text.trim() == "") || locationController.text.trim() == "" || (foodController.text.trim() == "") || (descriptionController.text.trim() == "") || (priceController.text.trim() == "") || (ratingController.text.trim() == "");

		return Padding
		(
			padding: const EdgeInsets.only(top: 15.0),
			child: Column
			(
				children:
				[
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
                        label: const Text('Rating'),
                        dropdownMenuEntries: ratingList,
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
							list.uploadPost(context, newPost(restaurantController, locationController, foodController, descriptionController, priceController, ratingController));
							resetControllers();
						},
						child: const Text("Post")
					),
				],
			),
		);
  	}

	Post newPost(TextEditingController restaurant, TextEditingController location, TextEditingController food, TextEditingController description, TextEditingController price, TextEditingController rating)
	{
		Post post = Post(restaurant.text.trim(), location.text.trim(), food.text.trim(), description.text.trim(), double.parse(price.text.trim()), int.parse(rating.text.trim()));
		return post;
	}

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
	final List<Post> postsList = List.empty(growable: true);

	void uploadPost(BuildContext context, Post post)
	{
		postsList.insert(0, post);
		notifyListeners();

		final RestaurantFoldersList restaurantFoldersList = context.read<RestaurantFoldersList>(); // Cant do watch, have to do read. Watch rebuilds widgets, i just want to access data, not build any widgets in this area
		makeFolders(context, restaurantFoldersList, post.restaurant, post.location);
	}

	void makeFolders(BuildContext context, RestaurantFoldersList restaurantList, String restaurantName, String locationName)
	{
		final List<LocationFolder> locationList = List.empty(growable: true);

		if(restaurantList.restList.isEmpty)
		{
			restaurantList.createFolder(context, RestaurantFolder(restaurantName, locationList), LocationFolder(locationName));
		}
		else
		{
			for (RestaurantFolder restFolder in restaurantList.restList)
			{
				for(LocationFolder locFolder in restaurantList.locList)
				{
					if(restFolder.folderName.trim().toLowerCase() != restaurantName.trim().toLowerCase() && locFolder.folderName.trim().toLowerCase() != locationName.trim().toLowerCase())
					{
						final List<LocationFolder> locationList = List.empty(growable: true);
						restaurantList.createFolder(context, RestaurantFolder(restaurantName, locationList), LocationFolder(locationName));
						return;
					}
				}
			}	
		}
	}
}