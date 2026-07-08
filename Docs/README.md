# Food Files Documentation

---

<details>
<summary><h3 style="display: inline;">Non-Git Tracked Files</h3></summary>

Ask me about these files:
- `FoodFiles\Frontend\food_files_app\android\app\src\main\res\values\mapbox_access_token.xml`
- `FoodFiles\.vscode\launch.json`
- `FoodFiles\Frontend\food_files_app\.env`

</details>

---

<details>
<summary><h3 style="display: inline;">MISE</h3></summary>

### Team Environment Onboarding Guide

We are using **`mise`** to completely automate our development environments. This ensures all three of us are using the exact same versions of Flutter, Java, and local configurations without manually installing tools or breaking paths.

Follow these steps once to configure your machine.

---

### Step 1: Install `mise` on your computer

Open your local terminal interface and run the installation script for your operating system:

* **Windows (PowerShell):**
```powershell
winget install jdx.mise

```


* **macOS (Homebrew):**
```bash
brew install mise

```



*Note for Windows users: Add this to your System Variables Environment Path - C:\Users\USERNAME\AppData\Local\Microsoft\WinGet\Links - Then close and completely restart your terminal window.*

---

### Step 2: Enable Automated Tool Installations

Run this command in your terminal. This tells `mise` to instantly download missing project versions the second you open the project repository:

```bash
mise settings set auto_install true

```

---

### Step 3: Configure your Terminal Hook

We want `mise` to run dynamically without manual commands. Add the activation line to your system profile so it runs automatically in the background.

#### For Windows (PowerShell):

1. Execute this command to create and open your shell profile configuration:
```powershell
New-Item -Path $PROFILE -Type File -Force
notepad $PROFILE

```


2. Paste this exact automation script into the Notepad document, save, and exit:
```powershell
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Invoke-Expression (mise activate pwsh | Out-String)
    Start-Job -ScriptBlock { mise install --quiet } | Out-Null
}

```



#### For macOS (Zsh):

1. Run this command to append the hook configuration into your profile configuration:
```bash
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc

```



---

### Step 4: Install All Recommended Extensions
If mise doesn't automatically install the technologies we'll be using, then run in `FoodFiles\Frontend\food_files_app`:
```cmd
mise install

```

### Step 5: Install All Recommended Extensions
1. A pop-up notification will appear in the bottom-right corner after cloning stating:
> *"This repository contains recommended extensions."*
2. Click **Install All**.

</details>

---

<details>
<summary><h3 style="display: inline;">Supabase</h3></summary>

## Prerequisites & Installation

### Step 1: Install Docker Desktop

The Supabase CLI uses Docker to orchestrate the local database engine and its peripheral services.

1. Download the installer for your operating system:
* **Windows:** Ensure WSL 2 (Windows Subsystem for Linux) is installed and configured before running the Docker Desktop installer.
* **macOS:** Select the correct version for your chip architecture (Apple Silicon vs Intel).


2. Run the installer and complete the setup wizard.
3. Launch Docker Desktop and verify the daemon is running in the background.

### Step 2: Start the Infrastructure

Ensure Docker Desktop is active, then execute the startup command:

```bash
mise exec -- supabase start

```

> **Note:** The initial execution takes 3-5 minutes to download official Docker images (Postgres, GoTrue Auth engine, PostgREST, and Supabase Studio). Subsequent starts execute in under 10 seconds.

Upon successful initialization, the terminal outputs your local infrastructure credentials:

```text
Started supabase local development setup.

API URL:          http://127.0.0.1:54321
DB URL:           postgresql://postgres:postgres@localhost:54322/postgres
Studio URL:       http://localhost:54323
anon key:         eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

```

Access the local graphical dashboard at `http://localhost:54323` to manage tables, run SQL queries, and inspect authentication states offline.

---

## Daily Operational Commands

Use these commands for daily environment management:

| Command | Action | Use Case |
| --- | --- | --- |
| `mise exec -- supabase start` | Boots all local backend containers. | Start of work session. |
| `mise exec -- supabase stop` | Halts the container cluster. | End of work session to free up system RAM. |
| `mise exec -- supabase status` | Outputs active API ports, database connection keys, and states. | Verifying environment health. |
| `mise exec -- supabase db reset` | Resets the local database and re-runs all migrations in `/migrations`. | Reverting bad local data states or syncing with upstream schema changes. |

---

## Architectural Mapping

The local Supabase environment runs as a decoupled cluster of individual Docker containers mapping to the following default ports:

| Service | Local External Port | Internal Purpose |
| --- | --- | --- |
| **Kong** | `54321` | API Gateway proxying requests to sub-services. |
| **PostgreSQL** | `54322` | Core database engine. |
| **Supabase Studio** | `54323` | Web-based management dashboard. |
| **Inbucket** | `54324` | Local SMTP server to intercept and test authentication emails. |

</details>

---

<details>
<summary><h3 style="display: inline;">Wireless Android Debugging</h3></summary>

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

</details>

---

<details>
<summary><h3 style="display: inline;">Supabase & Local Hosting</h3></summary>

## Supabase Local Hosting Setup

To test the application on physical mobile devices or distinct local workstations, you must route API calls through your computer's local network IP address rather than `localhost`.

### 1. Find Your Local Network IP Address

Your mobile device needs your laptop's specific internal IPv4 address to communicate over your shared Wi-Fi network. Find your address using your operating system's terminal interface:

* **Windows (PowerShell / CMD):** Run `ipconfig` and look for the **IPv4 Address** under your active wireless or ethernet adapter (typically starting with `192.168.` or `10.`).
* **macOS / Linux (Terminal):** Run `ipconfig getifaddr en0` (Mac) or `ip addr show` (Linux) to print your active local routing assignment directly.

---

### 2. Configure the Environment Variable

Local configurations are managed through an untracked environment file to prevent team layout conflicts in the shared Git history.

1. Navigate to the frontend application configuration folder:
```bash
cd FoodFiles\Frontend\food_files_app

```

2. Create a `.env` file

3. Add in the following line, with XXX being your computer's real IP:
`LOCAL_COMPUTER_IP=XXX`

</details>

---