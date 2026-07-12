import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Utils
{
	// If the condition is true, the first option is chosen, otherwise the second is chosen. T allows for any datatype to be returned
	static T whatModeIsIt<T>(bool condition, T option1, T option2)
	{
		return condition ? option1 : option2;
	}

	static Color getBackgroundColor(ThemeData theme)
	{
		return theme.scaffoldBackgroundColor;
	}

	static Color? getRatingColour(double rating, ThemeData theme)
	{
		final bool lightMode = theme.brightness == Brightness.light;

		if(lightMode)
		{
			return Color.lerp(const Color.fromARGB(225, 255, 0, 0), const Color.fromARGB(255, 50, 255, 0), (rating / 10));
		}
		else
		{
			return Color.lerp(const Color.fromARGB(255, 152, 27, 27), const Color.fromARGB(255, 27, 152, 5), (rating / 10)); // Slightly duller, so that it doesn't look weirdly neon on dark mode
		}
	}

	static double screenWidth(BuildContext context)
	{
		return MediaQuery.sizeOf(context).width;
	}
}

class FoodFilesTitle extends StatelessWidget
{
	const FoodFilesTitle({super.key});

	@override
	Widget build(BuildContext context)
	{
		return Text
		(
			"Food Files",
			textAlign: TextAlign.center,
			style: GoogleFonts.allura
			(
				textStyle: const TextStyle
				(
					fontWeight: FontWeight.bold,
					fontSize: 50,
					letterSpacing: 2
				)
			)
		);
	}
}

class PageSwitcher extends StatelessWidget
{
	final Widget nextPage;

	const PageSwitcher({super.key, required this.nextPage});

	@override
	Widget build(BuildContext context)
	{
		return ColoredBox
		(
			color: Utils.getBackgroundColor(Theme.of(context)), // Sets the background colour
			child: AnimatedSwitcher // Automatically cross-fades between pages when the page changes.
			(
				duration: const Duration(milliseconds: 200), // Cross fade duration
				child: nextPage, // Goes to the next page
			)
		);
	}
}