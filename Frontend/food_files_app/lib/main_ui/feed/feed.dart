import 'dart:io';
import 'package:food_files_app/main_ui/post/post.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:flutter/material.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget
{
	final String? restaurantName;
	final String? locationName;
	final bool cameFromProfile;

  	const FeedPage({super.key, this.restaurantName, this.locationName, required this.cameFromProfile}); // Used to show every post
  	const FeedPage.filedMeals(this.restaurantName, this.locationName, this.cameFromProfile, {super.key}); // Used in the Location Folder to show specific posts that match both the restaurant and the location of the parent folders

	@override
	Widget build(BuildContext context)
	{
		if(cameFromProfile == false) // If cameFromProfile is null, then it definitely won't be true, so I just have false as the backup
		{
			return RenderedPage(restaurantName: restaurantName, locationName: locationName, cameFromProfile: false);
		}
		else
		{
			return Scaffold
			(
				backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
				appBar: AppBar(title: const Text("Food Files")), // Adds this text, plus a back button
				body: RenderedPage(restaurantName: restaurantName, locationName: locationName, cameFromProfile: true)
			);
		}
  	}
}

class RenderedPage extends StatelessWidget
{
	final String? restaurantName;
	final String? locationName;
	final bool cameFromProfile;

	const RenderedPage({super.key, required this.restaurantName, required this.locationName, required this.cameFromProfile});

	@override
	Widget build(BuildContext context)
	{
		final AllPosts list = context.watch<AllPosts>();

		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displaySmall;

		return Column
		(
			children:
			[
				cameFromProfile == false ? Text("Food Files", textAlign: TextAlign.center, style: GoogleFonts.allura(textStyle: textStyle?.copyWith(fontWeight: FontWeight.bold))) : const SizedBox.shrink(),
				Expanded // Below the food files card is a list of every post within an expanded widget so that it fits within the phone and doesn't overflow. Inside a Column, a ListView (which has infinite height) will crash the app with a "Vertical viewport was given unbounded height" error unless wrapped in Expanded.
				(
					child: Feed(list: list, restaurantName: restaurantName, locationName: locationName)
				)
			],
		);
	}
}

class Feed extends StatelessWidget
{
	final AllPosts list;
	final String? restaurantName;
	final String? locationName;

	const Feed({super.key, required this.list, required this.restaurantName, required this.locationName});

	@override
	Widget build(BuildContext context)
	{
		List<Post> listToDisplay = list.postsList; // list.postsList is final, so it can't be a setter, so i make a new reference to the original master list. It's not a copy, its just a reference so it's nearly instantaneous and uses negligible memory.

		// If the restaurant and location aren't null, then filter the list to only show the filed meals
		if(restaurantName != null && locationName != null)
		{
			listToDisplay = listToDisplay
			.where
			(
				(post) => post.restaurant.trim().toLowerCase() == restaurantName?.trim().toLowerCase() && post.location.trim().toLowerCase() == locationName?.trim().toLowerCase()
			).toList(); // This actually does make a new list, but is necessary to show the filtered list. Also helps ensure I don't tamper with the original master list
		}

		if(listToDisplay.isEmpty)
		{
			return const Center(child: Text("No meals have been filed :(")); // If the list is empty then only print this text
		}

		return ListView.builder // .builder is lazy, which means it only creates the PostWidgets that are actually visible on the screen
		(
			itemCount: listToDisplay.length, // Show every post within the list
			itemBuilder: (context, index)
			{
				return PostWidget(listToDisplay, index); // For every post in the list, make it a widget. The list and index need to be passed in so that the info in the posts can be accessed at every index
			}
		);
	}
}

class PostWidget extends StatelessWidget
{
	final List<Post> list;
	final int index;
	const PostWidget(this.list, this.index, {super.key});

	@override
	Widget build(BuildContext context)
	{
		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displayMedium;

		// At every index in the list, grab the info from the post
		final String restaurant = list[index].restaurant;
		final DateTime date = list[index].date;
		final String food = list[index].food;
		final String description = list[index].description;
		final String? image = list[index].image;
		final double price = list[index].price;
		final double rating = list[index].rating;

		return Card
		(
			child: AspectRatio
			(
				aspectRatio: 9/16,
				child: Padding
				(
					padding: const EdgeInsets.all(16.0),
					child: Column
					(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children:
						[
							Row
							(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children:
								[
									Text(restaurant),
									Text(food),
									const Icon(Icons.person)
								],
							),

							Center
							(
								child: Carousel(description: description, image: image)
							),

							Row
							(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children:
								[
									const Icon(Icons.thumbs_up_down_rounded),
									const Icon(Icons.comment_rounded),
									Text(formattedPrice(price)),
									Text("$rating/10", style: TextStyle(color: Utils.getRatingColour(rating, theme)))
								]

							)
						],
					),
				)
			),
		);
	}

	String formattedPrice(double numberPrice)
	{
		String locale = Platform.localeName; // Gets the device's locale
		final String price = NumberFormat.simpleCurrency(locale: locale).format(numberPrice); // Formats it to have proper decimal count, symbol and separator placement and symbol ($12.50, 12,50 €)
		return price;
	}
}

class Carousel extends StatelessWidget
{
	final String description;
	final String? image;

  	const Carousel({super.key, required this.description, this.image});
	
	@override
	Widget build(BuildContext context)
	{
		return custom_carousel.CarouselSlider.builder
		(
			itemCount: 2, // 1 Description + 1 Image = 2 Items
			itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex)
			{
				if(image != null)
				{
					return switch(itemIndex)
					{
						0 => Description(description: description),
						1 => FoodPicture(picture: image!),
						_ => Description(description: description)
					};
				}
				else
				{
					return Description(description: description);
				}
			},
			options: custom_carousel.CarouselOptions
			(
				initialPage: 0,
				enableInfiniteScroll: true,
				reverse: true,
				autoPlay: false,
				enlargeCenterPage: true,
				scrollDirection: Axis.horizontal
			)
		);
	}
}

class Description extends StatelessWidget
{
	final String description;

  	const Description({super.key, required this.description});
	
	@override
	Widget build(BuildContext context)
	{
		return Text(description, maxLines: 10, overflow: TextOverflow.ellipsis);
	}	
}

class FoodPicture extends StatelessWidget
{
	final String picture;

  	const FoodPicture({super.key, required this.picture});
	
	@override
	Widget build(BuildContext context)
	{
		return Image.file
		(
			File(picture),
			cacheWidth: 400, // Memory optimization
			errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
		);
	}
}

// infinite list scroll
	// larger container that holds:
		// name of restaurant top left
		// pfp top right
		// description in the middle
		// swipe left to get to an image
		// like button
		// comment button
		// price that was paid
		// original price (only shown if the paid price was discounted, make this a double thats conditionally shown on a boolean)
		// rating out of 10 (should change colour depending on the goodness (red to green))