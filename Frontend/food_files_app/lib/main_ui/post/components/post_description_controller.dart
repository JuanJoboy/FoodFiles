import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/post/post_controller.dart';

enum DescriptionFieldToSave
{
	title,
	food,
	description,
	price
}

class DescriptionNotifier extends ChangeNotifier
{
	// PRIVATE FIELDS
	// The text field controllers, they need to be individual. If they shared each other then they'd have the same text
	final TextEditingController _titleController = TextEditingController();
	final TextEditingController _foodController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _priceController = TextEditingController();

	String? _imagePath;
	double _sliderRating = 5;

	String postTitle = "";
	String postFood = "";
	String postDescription = "";
	String postPrice = "";
	double postRating = 5;

	AllPosts? _allPosts;

	// GETTERS
	TextEditingController get titleController => _titleController;
	TextEditingController get foodController => _foodController;
	TextEditingController get descriptionController => _descriptionController;
	TextEditingController get priceController => _priceController;
	String? get imagePath => _imagePath;
	double get sliderRating => _sliderRating;

	AllPosts? get allPosts => _allPosts;

	// SETTERS
	void setImagePath(String? imagePath)
	{
		_imagePath = imagePath;
		notifyListeners();
	}

	void setSliderRating(double sliderRating)
	{
		_sliderRating = double.parse(sliderRating.toStringAsFixed(1));
		notifyListeners();
	}

	void setAllPosts(AllPosts? allPosts)
	{
		_allPosts = allPosts;
	}

	// FUNCTIONS
	@override
	void dispose()
	{
		// Must be disposed to avoid memory leaks
		_titleController.dispose();
		_foodController.dispose();
		_descriptionController.dispose();
		_priceController.dispose();
		super.dispose();
	}

	void restoreTextValues()
	{
		_titleController.text = postTitle;
		_foodController.text = postFood;
		_descriptionController.text = postDescription;
		_priceController.text = postPrice;
	}

	void updateControllers({String? title, String? food, String? description, String? price, double? rating})
	{
		// If the parameter isn't null, then save the value, so that when the page rebuilds, it rebuilds with this value
		if(title != null) postTitle = title;
		if(food != null) postFood = food;
		if(description != null) postDescription = description;
		if(price != null) postPrice = price;
		if(rating != null) postRating = rating;
	}

	Post newPost(String restaurant, String location, DateTime calendar)
	{
		// Trims and parses all the values so that everything is uploaded properly and without any excess
		Post post = Post(restaurant.trim(), location.trim(), calendar, _titleController.text.trim(), _foodController.text.trim(), _descriptionController.text.trim(), imagePath?.trim(), double.parse(_priceController.text.trim()), _sliderRating);

		resetControllers(); // And make all the fields blank

		return post;
	}

	void resetControllers()
	{
		_titleController.clear();
		_foodController.clear();
		_descriptionController.clear();
		_priceController.clear();
		_imagePath = null;
		_sliderRating = 5;

		updateControllers(title: _titleController.text, food: _foodController.text, description: _descriptionController.text, price: _priceController.text, rating: _sliderRating);

		notifyListeners();
	}

	bool areFieldsEmpty()
	{
		return (_titleController.text.trim().isEmpty) || (_foodController.text.trim().isEmpty) || (_descriptionController.text.trim().isEmpty) || (_priceController.text.trim().isEmpty); // Ensures that all the fields are filled before a post can be posted
	}
}