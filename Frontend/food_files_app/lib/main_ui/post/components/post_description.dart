import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_files_app/main_ui/post/components/post_camera.dart';
import 'package:food_files_app/main_ui/post/post.dart';
import 'package:food_files_app/utilities/utilities.dart';
import 'package:provider/provider.dart';

class DescriptionPage extends StatefulWidget
{
	final String restaurant;
	final String location;
	final DateTime day;

  	const DescriptionPage(this.restaurant, this.location, this.day, {super.key});

	@override
	State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage>
{
	// The text field controllers, they need to be individual. If they shared each other then they'd have the same text
	final TextEditingController titleController = TextEditingController();
	final TextEditingController foodController = TextEditingController();
	final TextEditingController descriptionController = TextEditingController();
	final TextEditingController priceController = TextEditingController();
	final TextEditingController ratingController = TextEditingController();

	double? selectedRating = 5; // Just nice to auto place in the middle. And also i think its needed to set the actual rating

	List<DropdownMenuEntry<double>> ratingList = [for(int i = 0; i <= 100; i++) DropdownMenuEntry(value: i / 10, label: (i / 10).toStringAsFixed(1))]; // Ensures that i dont get any rounding weirdness like 4.99999

	String? imagePath;

	late AllPosts _list;

	@override
	void dispose()
	{
		// Must be disposed to avoid memory leaks
		super.dispose();
		titleController.dispose();
		foodController.dispose();
		descriptionController.dispose();
		priceController.dispose();
		ratingController.dispose();
	}

	@override void initState()
	{
    	super.initState();
		final AllPosts list = context.read<AllPosts>(); // Since there's no context available here, I just read, rather than making and adding the widget to the tree
		_list = list; // Initializes the field

		// On the first go, it sets all the fields to blank, but then whenever the user goes to another page, and then back here, the page will rebuild with the previous values. This is so that the fields don't keep resetting
		titleController.text = _list.postTitle;
		foodController.text = _list.postFood;
		descriptionController.text = _list.postDescription;
		priceController.text = _list.postPrice;
		ratingController.text = _list.postRating;
  	}

	@override
	Widget build(BuildContext context)
	{
		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displaySmall;

		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			appBar: AppBar(title: const Text("Description")),
			body: SingleChildScrollView
			(
				child: Padding
				(
					padding: const EdgeInsets.all(15.0),
					child: Column // try Stack
					(
						children:
						[
							// Restaurant
							immutableTextField("Restaurant", widget.restaurant, textStyle: textStyle),

							// Location
							immutableTextField("Location", widget.location, textStyle: textStyle),

							// Title
							textBox("Title", titleController, textStyle: textStyle, fieldToSave: 1),

							// Food
							textBox("Food", foodController, textStyle: textStyle, fieldToSave: 2),

							// Take Photo
							takePhoto(),

							// Display Photo
							displayPhoto(),

							// Description
							textBox("Description", descriptionController, textStyle: textStyle, fieldToSave: 3),

							// Price
							textBox("Price", priceController, textStyle: textStyle, fieldToSave: 4, priceField: true),

							// Rating
							ratingDropdown(),

							// Upload Button
							upload(),

							const SizedBox(height: 100)
						]
					)
				),
			)
		);
  	}

	Widget immutableTextField(String fieldName, String text, {TextStyle? textStyle})
	{
		return Card
		(
			child: Column
			(
				children:
				[
					Text(fieldName, style: textStyle?.copyWith(fontSize: 20)),
					Text(text, style: textStyle?.copyWith(fontSize: 20)),
				],
			),
		);
	}

	Widget textBox(String fieldName, TextEditingController controller, {TextStyle? textStyle, bool? priceField, int? fieldToSave})
	{
		return Card
		(
			child: Column
			(
				children:
				[
					Text(fieldName, style: textStyle?.copyWith(fontSize: 20)),

					TextField
					(
						style: textStyle?.copyWith(fontSize: 20),
						controller: controller,
						onChanged: (value)
						{
							// setState() isn't needed here because it's straight up not needed when saving the controllers text, and in regards to the upload condition, the upload button is wrapped in a listenable that does the work for us
							switch(fieldToSave)
							{
								case 1: _list.updateControllers(title: value);
								case 2: _list.updateControllers(food: value);
								case 3: _list.updateControllers(description: value);
								case 4: _list.updateControllers(price: value);
							}
						},
						inputFormatters: priceField == true ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))] : null
					),
				],
			),
		);
	}

	Widget takePhoto()
	{
		return InkWell
		(
			onTap: () async
			{
				final String? returnedPath = await Navigator.push
				(
					context,
					MaterialPageRoute(builder: (context) => const TakePictureScreen())
				);

				setState(()
				{
					imagePath = returnedPath;
				});
			},
			child: const Padding
			(
				padding: EdgeInsets.all(16.0),
				child: Icon(Icons.camera_alt_outlined)
			),
		);
	}

	Widget displayPhoto()
	{
		if(imagePath != null)
		{
			return Image.file
			(
				File(imagePath!),
				width: 200,
				height: 200,
				fit: BoxFit.cover,
				cacheWidth: 400, // Memory optimization
				errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
			);
		}
		else
		{
			return const Icon(Icons.local_pizza);
		}
	}

	Widget ratingDropdown()
	{
		return DropdownMenu<double>
		(
			controller: ratingController,
			label: const Text('Rating'), // The mini label on the widget
			dropdownMenuEntries: ratingList, // The list from 0 - 10
			onSelected: (double? rating)
			{
				selectedRating = rating;
				_list.updateControllers(rating: ratingController.text);
			},
		);
	}

	Widget upload()
	{
		return ListenableBuilder
		(
			listenable: Listenable.merge([titleController, foodController, descriptionController, priceController, ratingController]), // Combines all the controllers together to say "Track all these guys's changes"
			builder: (context, child)
			{
				return ElevatedButton
				(
					onPressed: areFieldsEmpty() ? null : () // if the fields are empty then grey out the button
					{
						_list.uploadPost(newPost(widget.restaurant, widget.location, widget.day, titleController, foodController, descriptionController, priceController, ratingController)); // If every field is filled in, upload the post

						Navigator.popUntil(context, (route) => route.isFirst); // Goes back until it reaches the first page created (the home page)
					},
					child: const Padding
					(
						padding: EdgeInsets.all(16.0),
						child: Text("Post", textAlign: TextAlign.center,),
					),
				);
			},
		);
	}

	// Im thinking like a big plus icon, but it should probably be sleeker and more compact
	// Below code shows an image, it does not open the camera roll
	// Widget uploadPhoto()
	// {
	// 	return Image.asset('assets/images/food.jpg');
	// }

	Post newPost(String restaurant, String location, DateTime calendar, TextEditingController title, TextEditingController food, TextEditingController description, TextEditingController price, TextEditingController rating)
	{
		// Trims and parses all the values so that everything is uploaded properly and without any excess
		Post post = Post(restaurant.trim(), location.trim(), calendar, title.text.trim(), food.text.trim(), description.text.trim(), imagePath?.trim(), double.parse(price.text.trim()), double.parse(rating.text.trim()));

		resetControllers(); // And make all the fields blank

		return post;
	}

	void resetControllers()
	{
		titleController.clear();
		foodController.clear();
		descriptionController.clear();
		priceController.clear();
		ratingController.clear();

		_list.updateControllers(title: titleController.text, food: foodController.text, description: descriptionController.text, price: priceController.text, rating: ratingController.text);
	}

	bool areFieldsEmpty()
	{
		return (titleController.text.trim().isEmpty) || (foodController.text.trim().isEmpty) || (descriptionController.text.trim().isEmpty) || (priceController.text.trim().isEmpty) || (ratingController.text.trim().isEmpty); // Ensures that all the fields are filled before a post can be posted
	}
}