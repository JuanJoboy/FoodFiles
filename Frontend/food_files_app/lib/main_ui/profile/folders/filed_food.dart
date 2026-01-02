import 'dart:io';
import 'package:currency_converter_pro/currency_converter_pro.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/post/post.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FiledFoodPage extends StatelessWidget
{
  	const FiledFoodPage({super.key});

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
				Card
				(
					color: Theme.of(context).brightness == Brightness.light ? theme.colorScheme.surfaceContainerLow : Colors.blueGrey,
					child: SizedBox
					(
						width: double.infinity,
						child: Padding
						(
							padding: const EdgeInsets.only(top: 15.0),
							child: Text("Food Files", textAlign: TextAlign.center ,style: GoogleFonts.allura(textStyle: textStyle?.copyWith(fontWeight: FontWeight.bold))),
						),
					)
				),

				Expanded
				(
					child: list.postsList.isNotEmpty ? ListView.builder
					(
						itemCount: list.postsList.length,
						itemBuilder: (context, index)
						{
							return PostWidget(list.postsList, index);
						},
					) : const Center(child: Text("No meals have been filed :(")) // If the list isn't empty then only print this text
				)
			],
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
		
		final String restaurant = list[index].restaurant;
		final String food = list[index].food;
		final String description = list[index].description;
		final double price = list[index].price;
		final int rating = list[index].rating;

		double extraPadding = 40; // Needed to make the break line between each post look symmetrical
		double deviceWidth = MediaQuery.of(context).size.width;
		final double topDistanceForBottomRow = 335;

		final bool lightMode = theme.brightness == Brightness.light;
		final Color darkCardColor = lightMode ? theme.colorScheme.onPrimaryFixed : theme.colorScheme.primaryFixed;
		final Color mediumCardColor = lightMode ? theme.colorScheme.onPrimaryFixedVariant : theme.colorScheme.primaryFixedDim;
		final Color lightCardColor = lightMode ? theme.colorScheme.primary : theme.colorScheme.primaryContainer;

		return Padding
		(
			padding: const EdgeInsetsGeometry.fromLTRB(0, 0, 0, 20),
			child: SizedBox
			(
				height: 440,
				width: double.infinity,
				child: Stack
				(
					children:
					[
						Divider
						(
							color: theme.colorScheme.surfaceContainerLowest, // Line color
							thickness: 3,       // Height of the line itself
						),

						// Restaurant
						displayText(context, theme, textStyle, restaurant, 1, FontWeight.bold, 25, CrossAxisAlignment.center, 10, darkCardColor, topDistance: 0 + extraPadding, leftDistance: 20, rightDistance: deviceWidth * 0.5, elevation: 10, roundedEdge: true),
						// Food
						displayText(context, theme, textStyle, food, 1, FontWeight.w600, 15, CrossAxisAlignment.center, 7, mediumCardColor, topDistance: 22 + extraPadding, leftDistance: deviceWidth * 0.51, rightDistance: deviceWidth * 0.2, elevation: 0, roundedEdge: true),
						// Profile Picture
						displayImage(context, Icons.account_circle, 55, const Color.fromARGB(255, 0, 0, 0), topDistance: 0 + extraPadding, leftDistance: deviceWidth * 0.75, rightDistance: 20),
						
						carouselScroller(lightCardColor, description, textStyle, lightMode, rating, theme),

						// Like
						// displayImage(context, Icons.thumb_up_rounded, 40, const Color.fromARGB(255, 255, 255, 255), topDistance: 200, leftDistance: deviceWidth * 0.1, rightDistance: deviceWidth * 0.75),
						displayImage2(context, Icons.thumb_up_rounded, 40, mediumCardColor, const Color.fromARGB(255, 255, 255, 255), topDistance: topDistanceForBottomRow + extraPadding, leftDistance: deviceWidth * 0.1, rightDistance: deviceWidth * 0.75),
						// Comment
						// displayImage(context, Icons.comment_rounded, 40, const Color.fromARGB(255, 255, 255, 255), topDistance: 200, leftDistance: deviceWidth * 0.3, rightDistance: deviceWidth * 0.6),
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
							child: Text(text, maxLines: lines, overflow: TextOverflow.ellipsis, style: textStyle?.copyWith(fontWeight: weight, fontSize: size, color: Utils.getColor(rating, theme))),
						),
					],
				),
			)
		);
	}

	Widget carouselScroller(Color lightCardColor, String description, TextStyle? textStyle, bool lightMode, int rating, ThemeData theme)
	{
		return Positioned(top: 100, left: 0, right: 0,child: custom_carousel.CarouselSlider.builder
		(
			itemCount: 2,
			itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex)
			{
				if(itemIndex == 0)
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
				else
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
		)) ;
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