# food_files_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Wireless Android Debugging for Flutter

This guide details the complete process for setting up standalone Android SDK Platform-Tools, configuring the system PATH, and establishing a wireless ADB connection without using cables.

---

## Step 1: Download and Extract Platform-Tools

1. Download the official **SDK Platform-Tools for Windows** directly from Google:
* URL: `https://developer.android.com/tools/releases/platform-tools`


2. Extract the downloaded ZIP file to a permanent, easily accessible directory on your local drive.
* Target path example: `C:\Users\username\Android\platform-tools`



---

## Step 2: Add ADB to Windows System PATH

To execute `adb` commands from any terminal window, the directory must be added to the system Environment Variables.

1. Press the **Windows Key**, type `env`, and select **Edit the system environment variables**.
2. In the System Properties window, click the **Environment Variables...** button at the bottom.
3. Under the **System variables** section, locate the variable named `Path`, select it, and click **Edit...**.
4. Click **New** on the right side of the window.
5. Paste the absolute path to your extracted folder: `C:\Android\platform-tools`
6. Click **OK** on all open windows to save the changes.
7. Open a new Terminal window and run the following command to verify the installation:
```terminal
adb --version

```


*The terminal must return the Android Debug Bridge version number.*

---

## Step 3: Prepare the Android Device

1. Open **Settings** on the Android device and navigate to **About Phone**.
2. Locate the **Build Number** and tap it 7 times consecutively until the notification "You are now a developer!" appears.
3. Return to the main **Settings** menu, select **System**, and open **Developer Options**.
4. Scroll down to the debugging section and enable **Wireless Debugging**.
5. Tap directly on the text **"Wireless Debugging"** to open its dedicated settings page.

---

## Step 4: Pair the Device via Terminal

1. On the Wireless Debugging page, tap **Pair device with pairing code**. A pop-up dialog will display three specific values:
* **Wi-Fi pairing code** (6-digit number)
* **IP address & Port** (e.g., `10.130.4.250:43211`)


2. Open Terminal on the computer and execute the pairing command using the IP and port shown on that specific pop-up dialog:
```terminal
adb pair <PAIRING_IP>:<PAIRING_PORT>

```


*Example:* `adb pair 10.130.4.250:43211`
3. The terminal will prompt: `Enter pairing code:`. Type the 6-digit code from the phone and press **Enter**.
4. The terminal must display: `Successfully paired to <IP>:<PORT>`.

---

## Step 5: Connect to the Device

1. Dismiss the pairing pop-up dialog on the phone by tapping **Cancel** or **OK** to return to the main Wireless Debugging page.
2. Locate the section labeled **IP address & Port** directly under the main toggle switch.
3. Note the new port number. This port is distinct from the pairing port used in Step 4.
4. In the Terminal window, execute the connection command using the main page IP and connection port:
```terminal
adb connect <MAIN_PAGE_IP>:<CONNECTION_PORT>

```


*Example:* `adb connect 10.130.4.250:36445`
5. The terminal must display: `connected to <IP>:<PORT>`.

---

## Step 6: Verify and Run in VS Code

1. Confirm the wireless connection is active by listing all connected target machines:
```terminal
adb devices

```


*The terminal output must display the device IP and connection port listed as `device`.*
2. Open VS Code.
3. Press the play button to Run & Debug.