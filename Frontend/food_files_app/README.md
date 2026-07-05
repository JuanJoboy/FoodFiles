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

This guide outlines the steps required to bypass Windows environment path restrictions and configure wireless debugging on a physical Android device using absolute file paths.

---

## 🛠️ Prerequisites

* An Android device and development computer connected to the **same Wi-Fi network**.
* A reliable USB data-sync cable (charging-only cables will not work).

---

## 📱 Step 1: Device Configuration

1. Navigate to **Settings** ➔ **About Phone**.
2. Tap **Build Number** exactly **7 times** to unlock Developer Options.
3. Return to the main settings menu, locate **Developer Options**, and enable **USB Debugging**.
4. Navigate to **Wi-Fi Settings**, select your active connection, and locate the device **IP Address** (e.g., `192.168.1.45`). Record this address for later use.

---

## 🔌 Step 2: Initial Hardware Tethering

1. Connect your Android device to the computer using the USB cable.
2. Confirm the security prompt on your mobile screen: check **"Always allow from this computer"** and select **Allow**.

---

## 💻 Step 3: Initialize Wireless Protocol

Open the integrated terminal in VS Code (`Ctrl + ~`) and execute the following commands sequentially. Replace `{USER}` with your local Windows profile folder name (e.g., `juanj_f3u9fci`).

### 1. Initialize TCP/IP Mode

Instruct the mobile device to listen for wireless debugging instructions on port 5555:

```cmd
C:\Users\{USER}\AppData\Local\Android\Sdk\platform-tools\adb.exe tcpip 5555

```

> **Expected Output:** `restarting in TCP mode port: 5555`

⚠️ **Disconnect the USB cable from your phone now before executing the next command.**

### 2. Establish Network Connection

Force the wireless connection over your local network using the IP address noted in Step 1:

```cmd
C:\Users\{USER}\AppData\Local\Android\Sdk\platform-tools\adb.exe connect 192.168.1.45:5555

```

> **Expected Output:** `connected to 192.168.1.45:5555`

---

## 🔍 Step 4: Verification & Diagnostic Port Routing

### 1. Verify Active Wireless Nodes

Confirm that Flutter detects the device over the wireless network:

```cmd
C:\Users\{USER}\AppData\Local\Android\Sdk\platform-tools\adb.exe devices

```

### 2. Fix Flutter VM Service Protocol Drops

If your debug session crashes due to an `HttpException` or unexpected connection termination, manually map the Flutter engine's diagnostic port back to your local workspace:

```cmd
C:\Users\{USER}\AppData\Local\Android\Sdk\platform-tools\adb.exe forward tcp:58219 tcp:58219

```

---

## 🚀 Execution

1. Verify that your physical phone is selected as the active target in the bottom-right status bar of VS Code.
2. Navigate to the **Run and Debug** tab in the sidebar (`Ctrl + Shift + D`).
3. Ensure the configuration dropdown is set to **Flutter**.
4. Click **Start Debugging** (or press **F5**) to compile and launch your app wirelessly.