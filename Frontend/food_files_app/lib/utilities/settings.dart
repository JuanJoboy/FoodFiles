import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin Settings<T>
{
	T get value;
	String get name;
	String get symbol;
	bool get isBase;
}

// BaseSettingsNotifier has to specify what Settings object it has, since it has a T
abstract class BaseSettingsNotifier<T extends Settings> extends ChangeNotifier
{
	bool isBaseMode = false;
	String get modeName; // Is a getter so that the subclasses don't overwrite each other's data on the users phone. Every class gets their own key for their own preference

	// The subclasses will provide the two options
	T get baseOption;
	T get altOption;

	// This computed property handles the toggle for the whole app
	T get currentUnit => isBaseMode ? altOption : baseOption;

	Future<void> init() async
	{
		await loadMode();
		notifyListeners();
	}

	void updateMode(bool newValue)
	{
		isBaseMode = newValue;
		changeMode();

		notifyListeners();
	}

	void changeMode()
	{
		saveMode();

		notifyListeners();
	}

	Future<void> saveMode() async
	{
		SharedPreferences preferences = await SharedPreferences.getInstance();
		preferences.setBool(modeName, isBaseMode);
	}

	Future<void> loadMode() async
	{
		SharedPreferences preferences = await SharedPreferences.getInstance();
		isBaseMode = preferences.getBool(modeName) ?? false;

		notifyListeners();
	}
}

enum ThemeSetting with Settings
{
	lightMode(value: ThemeMode.light, name: 'Light Mode', symbol: 'lightMode', isBase: true),
	darkMode(value: ThemeMode.dark, name: 'Dark Mode', symbol: 'darkMode', isBase: false);

	@override
	final ThemeMode value;
	@override
	final String name;
	@override
	final String symbol;
	@override
	final bool isBase;

	const ThemeSetting({required this.value, required this.name, required this.symbol, required this.isBase});
}

class ThemeNotifier extends BaseSettingsNotifier<ThemeSetting>
{
	@override
	String get modeName => "theme_preference";
	
	@override
	ThemeSetting get baseOption => ThemeSetting.lightMode;

	@override
	ThemeSetting get altOption => ThemeSetting.darkMode;
}

abstract class SettingsSwitch<T extends BaseSettingsNotifier> extends StatelessWidget
{
	IconData get initialIcon;
	IconData get secondIcon;

  	const SettingsSwitch({super.key});

	@override
	Widget build(BuildContext context)
	{
		// Generics allow context.watch<T>() to work dynamically for the subclass
    	final notifier = context.watch<T>(); // This is essentially the same as calling something like watchNotifier(BuildContext context) where that method returned context.watch<notifier>(); and every subclass was forced to implement it with the type of BaseSettingsNotifier that they are

		final bool isBaseMode = context.watch<T>().isBaseMode;
		final bool isDarkMode = context.watch<ThemeNotifier>().isBaseMode;

		return Switch
		(
			value: isBaseMode,
			onChanged: (newValue)
			{
				notifier.updateMode(newValue);
			},
			thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states)
			{
				if(states.contains(WidgetState.selected))
				{
					return Icon(initialIcon, size: 20);
				}

				return Icon(secondIcon, size: 20);
			}),
			thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states)
			{
				if(states.contains(WidgetState.selected))
				{
					if(isDarkMode)
					{
						return isBaseMode ? Colors.black : Colors.white;
					}
					else
					{
						return isBaseMode ? Colors.white : Colors.black;
					}
				}
				if(isDarkMode)
				{
					return isBaseMode ? Colors.black : Colors.white;
				}
				else
				{
					return isBaseMode ? Colors.white : Colors.black;
				}
			}),

			inactiveTrackColor: Colors.amber[300],
			activeTrackColor: Colors.blue[200],
		);
	}
}

class DarkModeSwitch extends SettingsSwitch<ThemeNotifier>
{
	@override
	IconData get initialIcon => Icons.nights_stay_rounded;
	@override
	IconData get secondIcon => Icons.sunny;

  	const DarkModeSwitch({super.key});
}