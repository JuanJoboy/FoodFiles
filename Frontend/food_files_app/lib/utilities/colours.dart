import 'package:flutter/material.dart';

// ThemeExtension allows you to add custom, strongly-typed design tokens
class AppColours extends ThemeExtension<AppColours>
{
	// Defines the custom colour properties. Using nullable fields ensures compatibility with color interpolation methods.
	final Color? text;
    final Color? backgroundColour;

	// Constant constructor allows this extension to be instantiated at compile-time when building themes.
    const AppColours
    (
        {
			required this.text,
            required this.backgroundColour,
        }
    );
	
	// Not really used but is a required method for the extension
	// The copyWith method allows the framework or developers to create a new instance of AppColours while overriding only specific fields.
    @override
    AppColours copyWith
    (
        {
			Color? text,
            Color? backgroundColour,
        }
    )
    {
		// If a new value is passed, use it. Otherwise, fall back to the current instance's value.
        return AppColours
        (
			text: text ?? this.text,
            backgroundColour: backgroundColour ?? this.backgroundColour,
        );
    }

	// The lerp method handles linear interpolation between two themes. Flutter calls this automatically during theme switch animations to smoothly transition colours over time (t).
    @override
    AppColours lerp(ThemeExtension<AppColours>? other, double t)
    {
        if (other is! AppColours)
        {
            return this;
        }

        return AppColours
        (
			text: Color.lerp(text, other.text, t),
            backgroundColour: Color.lerp(backgroundColour, other.backgroundColour, t),
        );
    }
}