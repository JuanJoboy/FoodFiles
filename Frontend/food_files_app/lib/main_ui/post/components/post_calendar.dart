import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/post/components/post_description.dart';
import 'package:food_files_app/utilities/utilities.dart';

class CalendarPage extends StatefulWidget
{
	final String restaurant;
	final String location;

	const CalendarPage(this.restaurant, this.location, {super.key});

	@override
	State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
{
	@override
  	Widget build(BuildContext context)
	{
		DateTime selectedDay = DateTime.now(); // The day that's actually selected

		return Scaffold
		(
			backgroundColor: Utils.getBackgroundColor(Theme.of(context)),
			appBar: AppBar(title: const Text("Calendar")),
			body: Padding
			(
				padding: const EdgeInsets.all(15.0),
				child: Column
				(
					children:
					[
						CalendarDatePicker
						(
							initialDate: DateTime.now(),
							firstDate: DateTime(1900),
							lastDate: DateTime(2100),
							onDateChanged: (DateTime day) => selectedDay = day
						),

						InkWell // This is a button
						(
							onTap: ()
							{
								Navigator.push
								(
									context,
									MaterialPageRoute(builder: (context) => PageSwitcher(nextPage: DescriptionPage(widget.restaurant, widget.location, selectedDay)))
								);
							},
							child: const Padding
							(
								padding: EdgeInsets.all(16.0),
								child: Text("Next", textAlign: TextAlign.center,),
							),
						),
					],
				)
			)
		);
  	}
}