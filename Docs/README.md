# FoodFiles

## Non-Git Tracked Files
- FoodFiles\Frontend\food_files_app\android\app\src\main\res\values\mapbox_access_token.xml
- FoodFiles\.vscode\launch.json

## MISE
# Team Environment Onboarding Guide

We are using **`mise`** to completely automate our development environments. This ensures all three of us are using the exact same versions of Flutter, Java, and local configurations without manually installing tools or breaking paths.

Follow these steps once to configure your machine.

---

### Step 1: Install `mise` on your laptop

Open your local terminal interface and run the installation script for your operating system:

* **Windows (PowerShell):**
```powershell
winget install jdx.mise

```


* **macOS (Homebrew):**
```bash
brew install mise

```



*Note for Windows users: Add this to your System Variables Environment Path - C:\Users\USERNAME\AppData\Local\Microsoft\WinGet\Links - Then lose and completely restart your terminal window.*

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
1. A pop-up notification will appear in the bottom-right corner after cloning stating:
> *"This repository contains recommended extensions."*
2. Click **Install All**.