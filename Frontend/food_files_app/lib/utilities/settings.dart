import 'package:flutter/material.dart';
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