import 'dart:io';
// import 'package:currency_converter_pro/currency_converter_pro.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:flutter/material.dart';
// import 'package:food_files_app/main_ui/post/post.dart';
import 'package:food_files_app/main_ui/post/post2.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget
{
	// These nullable fields are used for the filedMeals constructor
	final String? restaurantName;
	final String? locationName;

  	const FeedPage({super.key, this.restaurantName, this.locationName}); // Used to show every post
  	const FeedPage.filedMeals(this.restaurantName, this.locationName, {super.key}); // Used in the Location Folder to show specific posts that match both the restaurant and the location of the parent folders

	@override
	Widget build(BuildContext context)
	{
		final AllPosts list = context.watch<AllPosts>();

		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displaySmall;

		const Widget noMealsText = Center(child: Text("No meals have been filed :("));

		return Column
		(
			children:
			[
				Card // Puts a card at the top that says "Food Files"
				(
					color: Utils.getBackgroundColor(theme),
					child: SizedBox // Makes a box with a set size so that I can put the width below, and make the food files banner at the top take up the entire phone width
					(
						width: double.infinity, // Makes the width of the space as big as the phone
						child: Padding
						(
							padding: const EdgeInsets.only(top: 15.0),
							child: Text("Food Files", textAlign: TextAlign.center, style: GoogleFonts.allura(textStyle: textStyle?.copyWith(fontWeight: FontWeight.bold))),
						),
					)
				),

				Expanded // Below the food files card is a list of every post within an expanded widget so that it fits within the phone and doesn't overflow. Inside a Column, a ListView (which has infinite height) will crash the app with a "Vertical viewport was given unbounded height" error unless wrapped in Expanded.
				(
					child: listOfMeals(list, noMealsText, restaurantName: restaurantName, locationName: locationName)
				)
			],
		);
  	}

	Widget listOfMeals(AllPosts list, Widget noMealsText, {String? restaurantName, String? locationName})
	{
		List<Post> listToDisplay = list.postsList; // list.postsList is final, so it can't be a setter, so i make a new reference to the original master list. It's not a copy, its just a reference so it's nearly instantaneous and uses negligible memory.

		// If the restaurant and location aren't null, then filter the list to only show the filed meals
		if(restaurantName != null && locationName != null)
		{
			listToDisplay = listToDisplay
			.where
			(
				(post) => post.restaurant.trim().toLowerCase() == restaurantName.trim().toLowerCase() && post.location.trim().toLowerCase() == locationName.trim().toLowerCase()
			).toList(); // This actually does make a new list, but is necessary to show the filtered list. Also helps ensure I don't tamper with the original master list
		}

		if(listToDisplay.isEmpty)
		{
			return noMealsText; // If the list is empty then only print this text
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
		final DateTime date = list[index].date;
		final String restaurant = list[index].restaurant;
		final String food = list[index].food;
		final String description = list[index].description;
		final double price = list[index].price;
		final int rating = list[index].rating;

		double deviceWidth = MediaQuery.of(context).size.width;
		double extraPadding = 40; // Needed to make the break line between each post look symmetrical
		final double sizedBoxHeight = 440; // the height of the sized box that contains all the info of the post
		final double topDistanceForBottomRow = sizedBoxHeight * 0.76; // The distance that all the stuff in the bottom row is from the top of the container

		final bool lightMode = theme.brightness == Brightness.light;
		final Color darkCardColor = lightMode ? theme.colorScheme.onPrimaryFixed : theme.colorScheme.primaryFixed;
		final Color mediumCardColor = lightMode ? theme.colorScheme.onPrimaryFixedVariant : theme.colorScheme.primaryFixedDim;
		final Color lightCardColor = lightMode ? theme.colorScheme.primary : theme.colorScheme.primaryContainer;

		return Padding
		(
			padding: const EdgeInsetsGeometry.fromLTRB(0, 0, 0, 20), // Adds 20 pixels to the bottom 
			child: SizedBox
			(
				height: sizedBoxHeight,
				width: double.infinity,
				child: Stack
				(
					children:
					[
						Divider
						(
							color: theme.colorScheme.surfaceContainerLowest, // Line color
							thickness: 3, // Height of the line itself
						),

						// Date
						displayText(context, theme, textStyle, DateFormat.yMMMd().format(date), 1, FontWeight.bold, 25, CrossAxisAlignment.center, 10, darkCardColor, topDistance: 160 + extraPadding, leftDistance: 20, rightDistance: deviceWidth * 0.5, elevation: 10, roundedEdge: true),

						// Restaurant
						displayText(context, theme, textStyle, restaurant, 1, FontWeight.bold, 25, CrossAxisAlignment.center, 10, darkCardColor, topDistance: 0 + extraPadding, leftDistance: 20, rightDistance: deviceWidth * 0.5, elevation: 10, roundedEdge: true),

						// Food
						displayText(context, theme, textStyle, food, 1, FontWeight.w600, 15, CrossAxisAlignment.center, 7, mediumCardColor, topDistance: 22 + extraPadding, leftDistance: deviceWidth * 0.51, rightDistance: deviceWidth * 0.2, elevation: 0, roundedEdge: true),

						// Profile Picture
						displayImage(context, Icons.account_circle, 55, const Color.fromARGB(255, 0, 0, 0), topDistance: 0 + extraPadding, leftDistance: deviceWidth * 0.75, rightDistance: 20),
						
						// Description + Image
						carouselScroller(lightCardColor, description, textStyle, lightMode, rating, theme),

						// Like
						displayImage2(context, Icons.thumb_up_rounded, 40, mediumCardColor, const Color.fromARGB(255, 255, 255, 255), topDistance: topDistanceForBottomRow + extraPadding, leftDistance: deviceWidth * 0.1, rightDistance: deviceWidth * 0.75),

						// Comment
						displayImage2(context, Icons.comment_rounded, 40, mediumCardColor, const Color.fromARGB(255, 255, 255, 255), topDistance: topDistanceForBottomRow + extraPadding, leftDistance: deviceWidth * 0.3, rightDistance: deviceWidth * 0.6),

						// Price
						displayText(context, theme, textStyle, formattedPrice(price), 1, FontWeight.w500, 25, CrossAxisAlignment.center, 3, mediumCardColor, topDistance: topDistanceForBottomRow + extraPadding, leftDistance: deviceWidth * 0.5, rightDistance: deviceWidth * 0.3, elevation: 5, roundedEdge: false),
						
						// Rating
						displayText(context, theme, textStyle, "$rating/10", 1, FontWeight.w500, 25, CrossAxisAlignment.center, 3, mediumCardColor, topDistance: topDistanceForBottomRow + extraPadding, leftDistance: deviceWidth * 0.75, rightDistance: deviceWidth * 0.1, elevation: 5, roundedEdge: false, rating: rating),
					],
				),
			)
		);
	}

	String formattedPrice(double numberPrice)
	{
		String locale = Platform.localeName; // Gets the device's locale
		// String? currencyName = NumberFormat.simpleCurrency(locale: locale).currencyName?.toLowerCase(); // Gets the 3 letter name of the currency (AUD))
		// if(currencyName != "aud")
		// {
		// 	number = CurrencyConverterPro().convertCurrency(amount: numberPrice, fromCurrency: currencyName!, toCurrency: "aud").toString().trim();
		// }
		final String price = NumberFormat.simpleCurrency(locale: locale).format(numberPrice); // Formats it to have proper decimal count, symbol and separator placement and symbol ($12.50, 12,50 €)
		return price;
	}

	Widget displayText(BuildContext context, ThemeData theme, TextStyle? textStyle, String text, int lines, FontWeight weight, double size, CrossAxisAlignment alignmentDirection, double paddingSize, Color cardColor, {double? topDistance, double? bottomDistance, double? leftDistance, double? rightDistance, double? elevation, bool? roundedEdge, int? rating})
	{
		return Positioned
		(
			top: topDistance,
			bottom: bottomDistance,
			left: leftDistance,
			right: rightDistance, // Pushes the right side of the card this many pixels to the left
			child: Card
			(
				color: cardColor,
				elevation: elevation,
				shape: roundedEdge == true ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : null,
				child: Column
				(
					crossAxisAlignment: alignmentDirection,
					children:
					[
						Padding
						(
							padding: EdgeInsets.all(paddingSize),
							child: Text(text, maxLines: lines, overflow: TextOverflow.ellipsis, style: textStyle?.copyWith(fontWeight: weight, fontSize: size, color: Utils.getColor(rating, theme))), // For the other cards that aren't the price card, the rating is null and shows a regular text colour based on the theme
						),
					],
				),
			)
		);
	}

	Widget carouselScroller(Color lightCardColor, String description, TextStyle? textStyle, bool lightMode, int rating, ThemeData theme)
	{
		return Positioned
		(
			top: 100,
			left: 0,
			right: 0,
			child: custom_carousel.CarouselSlider.builder
			(
				itemCount: 2, // 1 Description + 1 Image = 2 Items
				itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex)
				{
					if(itemIndex == 0) // Description Card
					{
						return Card
						(
							color: lightCardColor,
							elevation: 5,
							child: Padding
							(
								padding: const EdgeInsets.all(10),
								child: Text
								(
									description, maxLines: 10, overflow: TextOverflow.ellipsis, style: textStyle?.copyWith(fontWeight: lightMode ? FontWeight.normal : FontWeight.w600, fontSize: 20, color: Utils.getColor(null, theme))
								),
							),
						);
					}
					else // Image Card
					{
						return Image.asset('assets/images/food.jpg');
					}
				},
				options: custom_carousel.CarouselOptions
				(
					height: 200,
					viewportFraction: 0.8,
					initialPage: 0,
					enableInfiniteScroll: true,
					reverse: true,
					autoPlay: false,
					enlargeCenterPage: true,
					scrollDirection: Axis.horizontal
				)
			)
		) ;
	}
	
	Widget displayImage(BuildContext context, IconData iconSymbol, double size, Color color, {double? topDistance, double? bottomDistance, double? leftDistance, double? rightDistance})
	{
		return Positioned
		(
			top: topDistance,
			bottom: bottomDistance,
			left: leftDistance,
			right: rightDistance,
			child: Column
			(
				children:
				[
					Icon(iconSymbol, semanticLabel: "", size: size, color: color,)
				],
			),
		);
	}

	Widget displayImage2(BuildContext context, IconData iconSymbol, double size, Color cardColor, Color imageColor, {double? topDistance, double? bottomDistance, double? leftDistance, double? rightDistance})
	{
		return Positioned
		(
			top: topDistance,
			bottom: bottomDistance,
			left: leftDistance,
			right: rightDistance,
			child: Card
			(
				color: cardColor,
				elevation: 5,
				child: Column
				(
					children:
					[
						Padding
						(
							padding: const EdgeInsets.all(3),
							child: Icon(iconSymbol, semanticLabel: "", size: size, color: imageColor,),
						)
					],
				),
			)
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