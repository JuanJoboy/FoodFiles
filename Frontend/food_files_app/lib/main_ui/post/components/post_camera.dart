import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:food_files_app/main_ui/post/components/post_picture.dart';
import 'package:permission_handler/permission_handler.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget
{
	const TakePictureScreen({super.key});

  	@override
  	TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
{
	late CameraController _controller;
	Future<void>? _initializeControllerFuture; // Instead of making it a late variable, just make it a nullable future<void> so that it can handle being null
	bool _permissionGranted = false;

	Future<void> requestCameraPermission() async
	{
		PermissionStatus status = await Permission.camera.status; // Gets the users current camera permission status
		final cameras = await availableCameras(); // Obtain a list of the available cameras on the device.
		
		if(status.isDenied)
		{
			status = await Permission.camera.request();
		}

		if(status.isGranted)
		{
			_permissionGranted = true;

			if(!mounted) // Because asynchronous tasks can finish after a user has already left the page (e.g., they hit the 'back' button while the popup was open), I check if the widget still exists before updating the UI.
			{
				return;
			}

			setState(() // Forces a rebuild of the ui and sets the permission
			{
				final firstCamera = cameras.first; // Get a specific camera from the list of available cameras.

				_controller = CameraController(firstCamera, ResolutionPreset.medium); // To display the current output from the Camera, create a CameraController.

				_initializeControllerFuture = _controller.initialize(); // Next, initialize the controller. This returns a Future.
			});
		}
		else if(status.isPermanentlyDenied)
		{
			openAppSettings(); // If the user ticked "never ask again," open settings
		}		
	}

	@override
	void initState()
	{
		super.initState();

		WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await requestCameraPermission());
	}

	@override
	void dispose()
	{
		if(_permissionGranted)
		{
			_controller.dispose();
		}

		super.dispose();
	}

  	@override
  	Widget build(BuildContext context)
	{
    	return Scaffold
		(
      		appBar: AppBar(title: const Text('Say Cheese')),

      		// You must wait until the controller is initialized before displaying the camera preview. Use a FutureBuilder to display a loading spinner until the controller has finished initializing.
			body: FutureBuilder<void>
			(
				future: _initializeControllerFuture,
				builder: (context, snapshot)
				{
					if (snapshot.connectionState == ConnectionState.done && _permissionGranted)
					{
						return CameraPreview(_controller); // If the Future is complete and permission has been granted, display the preview.
					}
					else
					{
						return const Center(child: CircularProgressIndicator()); // Otherwise, display a loading indicator.
					}
				},
			),
			
      		floatingActionButton: FloatingActionButton
			(
        		onPressed: () async
				{
          			try
					{
						await _initializeControllerFuture; // Ensure that the camera is initialized.

						final image = await _controller.takePicture(); // Attempt to take a picture and get the file `image` where it was saved.

						if (!context.mounted)
						{
							return;
						}

						// If the picture was taken, display it on a new screen.
						await Navigator.of(context).push
						(
							MaterialPageRoute
							(
								builder: (context) => DisplayPictureScreen(imagePath: image.path),
							),
						);
					}
					catch (e)
					{
						print(e); // If an error occurs, log the error to the console.
          			}
				},

				child: const Icon(Icons.camera_alt),
			),
		);
	}
}