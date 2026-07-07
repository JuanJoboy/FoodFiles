import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_files_app/main_ui/post/components/post_camera.dart';
import 'package:food_files_app/main_ui/post/components/post_description_controller.dart';
import 'package:food_files_app/main_ui/post/post_controller.dart';
import 'package:food_files_app/utilities/colours.dart';
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
	@override
	void dispose()
	{
		// Must be disposed to avoid memory leaks
		super.dispose();
	}

	@override void initState()
	{
    	super.initState();
		final AllPosts allPosts = context.read<AllPosts>(); // Since there's no context available here, I just read, rather than making and adding the widget to the tree
		context.read<DescriptionNotifier>().setAllPosts(allPosts);

		// On the first go, it sets all the fields to blank, but then whenever the user goes to another page, and then back here, the page will rebuild with the previous values. This is so that the fields don't keep resetting
		context.read<DescriptionNotifier>().restoreTextValues();
  	}

	@override
	Widget build(BuildContext context)
	{
		final ThemeData theme = Theme.of(context);
		final TextStyle? textStyle = theme.textTheme.displaySmall;
		final DescriptionNotifier descriptionNotifier = context.read<DescriptionNotifier>();

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
							ImmutableTextField(header: "Restaurant", text: widget.restaurant, textStyle: textStyle),

							// Location
							ImmutableTextField(header: "Location", text: widget.location, textStyle: textStyle),

							// Title
							TextBox(header: "Title", textStyle: textStyle, controller: descriptionNotifier.titleController, fieldToSave: DescriptionFieldToSave.title),

							// Food
							TextBox(header: "Food", textStyle: textStyle, controller: descriptionNotifier.foodController, fieldToSave: DescriptionFieldToSave.food),

							// Take Photo
							const TakePhoto(),

							// Display Photo
							const DisplayPhoto(),

							// Description
							TextBox(header: "Description", textStyle: textStyle, controller: descriptionNotifier.descriptionController, fieldToSave: DescriptionFieldToSave.description),

							// Price
							TextBox(header: "Price", textStyle: textStyle, controller: descriptionNotifier.priceController, fieldToSave: DescriptionFieldToSave.price, isPriceField: true),

							// Rating
							const RatingSlider(),

							// Upload Button
							UploadButton(restaurant: widget.restaurant, location: widget.location, day: widget.day),

							const SizedBox(height: 100)
						]
					)
				),
			)
		);
  	}
}

class ImmutableTextField extends StatelessWidget
{
	final String header;
	final String text;
	final TextStyle? textStyle;

	const ImmutableTextField({super.key, required this.header, required this.text, this.textStyle});

	@override
	Widget build(BuildContext context)
	{
		return Card
		(
			child: Column
			(
				children:
				[
					Text(header, style: textStyle?.copyWith(fontSize: 20)),
					Text(text, style: textStyle?.copyWith(fontSize: 20)),
				],
			),
		);
	}
}

class TextBox extends StatelessWidget
{
	final String header;
	final TextStyle? textStyle;
	final TextEditingController controller;
	final DescriptionFieldToSave fieldToSave;
	final bool? isPriceField;

	const TextBox({super.key, required this.header, this.textStyle, required this.controller, required this.fieldToSave, this.isPriceField});

	@override
	Widget build(BuildContext context)
	{
		return Card
		(
			child: Column
			(
				children:
				[
					Text(header, style: textStyle?.copyWith(fontSize: 20)),

					TextField
					(
						style: textStyle?.copyWith(fontSize: 20),
						controller: controller,
						onChanged: (value)
						{
							// setState() isn't needed here because it's straight up not needed when saving the controllers text, and in regards to the upload condition, the upload button is wrapped in a listenable that does the work for us
							switch(fieldToSave)
							{
								case DescriptionFieldToSave.title: context.read<DescriptionNotifier>().updateControllers(title: value);
								case DescriptionFieldToSave.food: context.read<DescriptionNotifier>().updateControllers(food: value);
								case DescriptionFieldToSave.description: context.read<DescriptionNotifier>().updateControllers(description: value);
								case DescriptionFieldToSave.price: context.read<DescriptionNotifier>().updateControllers(price: value);
							}
						},
						inputFormatters: isPriceField == true ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))] : null,
						keyboardType: isPriceField == true ? const TextInputType.numberWithOptions(decimal: true) : null,
					),
				],
			),
		);
	}
}

class TakePhoto extends StatelessWidget
{
	const TakePhoto({super.key});

	@override
	Widget build(BuildContext context)
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

				if(context.mounted)
				{
					context.read<DescriptionNotifier>().setImagePath(returnedPath);
				}
			},
			child: const Padding
			(
				padding: EdgeInsets.all(16.0),
				child: Icon(Icons.camera_alt_outlined)
			),
		);
	}
}

class DisplayPhoto extends StatelessWidget
{
	const DisplayPhoto({super.key});

	@override
	Widget build(BuildContext context)
	{
		if(context.watch<DescriptionNotifier>().imagePath != null)
		{
			return Image.file
			(
				File(context.watch<DescriptionNotifier>().imagePath!),
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
}

class RatingSlider extends StatelessWidget
{
	const RatingSlider({super.key});

	@override
	Widget build(BuildContext context)
	{
		final ThemeData theme = Theme.of(context);
		final colour = theme.extension<AppColours>()!;

		return Slider
		(
			value: context.watch<DescriptionNotifier>().sliderRating,
			min: 0,
			max: 10,
			divisions: 100,
			onChanged: (newValue)
			{
				context.read<DescriptionNotifier>().setSliderRating(newValue);
			},
			label: context.watch<DescriptionNotifier>().sliderRating.toString(),
			thumbColor: Colors.indigo,
			activeColor: Utils.getRatingColour(context.watch<DescriptionNotifier>().sliderRating, theme),
			inactiveColor: colour.text,
		);
	}
}

class UploadButton extends StatelessWidget
{
	final String restaurant;
	final String location;
	final DateTime day;

	const UploadButton({super.key, required this.restaurant, required this.location, required this.day});

	@override
	Widget build(BuildContext context)
	{
		final DescriptionNotifier descriptionNotifier = context.read<DescriptionNotifier>();

		return ListenableBuilder
		(
			listenable: Listenable.merge([descriptionNotifier.titleController, descriptionNotifier.foodController, descriptionNotifier.descriptionController, descriptionNotifier.priceController, descriptionNotifier]),
			builder: (context, child)
			{
				return ElevatedButton
				(
					onPressed: descriptionNotifier.areFieldsEmpty() ? null : () // if the fields are empty then grey out the button
					{
						descriptionNotifier.allPosts?.uploadPost(descriptionNotifier.newPost(restaurant, location, day)); // If every field is filled in, upload the post

						Navigator.popUntil(context, (route) => route.isFirst); // Goes back until it reaches the first page created (the home page)
					},
					child: const Padding
					(
						padding: EdgeInsets.all(16.0),
						child: Text("Post", textAlign: TextAlign.center,),
					),
				);
			}
		);
	}
}