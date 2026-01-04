import 'package:flutter/material.dart';

enum Device
{
	phone,
	computer;
}

class Utils
{
	static Device deviceIs(BoxConstraints constraints)
	{
		double width = constraints.maxWidth;

		if(width < 600) // try 450
		{
			return Device.phone;
		}
		else
		{
			return Device.computer;
		}
	}

	static Color? getColor(int? rating, ThemeData theme)
	{
		final bool lightMode = theme.brightness == Brightness.light;

		if(rating != null)
		{
			if(lightMode)
			{
				return Color.lerp(const Color.fromARGB(225, 255, 0, 0), const Color.fromARGB(255, 50, 255, 0), (rating / 10));
			}
			else
			{
				return Color.lerp(const Color.fromARGB(255, 152, 27, 27), const Color.fromARGB(255, 27, 152, 5), (rating / 10)); // Slightly duller, so that it doesn't look weirdly neon on dark mode
			}
		}
		else
		{
			if(lightMode)
			{
				return theme.colorScheme.onPrimary;
			}
			else
			{
				return Colors.black;
			}
		}
	}

	static Color getBackgroundColor(ThemeData theme)
	{
		// If the mode is light, then return surfaceContainerLow, else return blueGrey if its dark mode
		return theme.brightness == Brightness.light ? theme.colorScheme.surfaceContainerLow : Colors.blueGrey;
	}

	static ColoredBox switchPage(BuildContext context, Widget nextPage)
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

	// static Color? getColor(int? rating, ThemeData theme)
	// {
	// 	final bool lightMode = theme.brightness == Brightness.light;

	// 	if(lightMode)
	// 	{
	// 		return switch(rating)
	// 		{
	// 			0 => const Color.fromARGB(225, 255, 0, 0),
	// 			1 => const Color.fromARGB(225, 255, 45, 0),
	// 			2 => const Color.fromARGB(255, 255, 90, 0),
	// 			3 => const Color.fromARGB(255, 255, 135, 0),
	// 			4 => const Color.fromARGB(255, 255, 180, 0),
	// 			5 => const Color.fromARGB(255, 255, 225, 0),
	// 			6 => const Color.fromARGB(255, 255, 255, 0),
	// 			7 => const Color.fromARGB(255, 210, 255, 0),
	// 			8 => const Color.fromARGB(255, 165, 255, 0),
	// 			9 => const Color.fromARGB(255, 120, 255, 0),
	// 			10 => const Color.fromARGB(255, 50, 255, 0),
	// 			_ => theme.colorScheme.onPrimary
	// 		};
	// 	}
	// 	else
	// 	{
	// 		return switch(rating)
	// 		{
	// 			0  => const Color.fromARGB(255, 152, 27, 27),
	// 			1  => const Color.fromARGB(255, 152, 52, 27),
	// 			2  => const Color.fromARGB(255, 152, 77, 27),
	// 			3  => const Color.fromARGB(255, 152, 102, 27),
	// 			4  => const Color.fromARGB(255, 152, 127, 27),
	// 			5  => const Color.fromARGB(255, 157, 157, 2),
	// 			6  => const Color.fromARGB(255, 127, 152, 27),
	// 			7  => const Color.fromARGB(255, 102, 152, 27),
	// 			8  => const Color.fromARGB(255, 77, 152, 27),
	// 			9  => const Color.fromARGB(255, 52, 152, 27),
	// 			10 => const Color.fromARGB(255, 27, 152, 5),
	// 			_ => Colors.black
	// 		};
	// 	}
	// }
}