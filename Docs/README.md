# FoodFiles

## Non-Git Tracked Files
- FoodFiles\Frontend\food_files_app\android\app\src\main\res\values\mapbox_access_token.xml
- FoodFiles\.vscode\launch.json

## MISE
### Team Environment Onboarding Guide

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
If the mise doesn't automatically install the techs, then run in FoodFiles\Frontend\food_files_app:
```powershell
mise install

```

### Step 5: Install All Recommended Extensions
1. A pop-up notification will appear in the bottom-right corner after cloning stating:
> *"This repository contains recommended extensions."*
2. Click **Install All**.



# Supabase Local Development Setup Guide

This guide covers installing, configuring, and managing a local Supabase infrastructure using Docker. Every team member must follow these steps to ensure environment parity.

---

## Prerequisites & Installation

### Step 1: Install Docker Desktop

The Supabase CLI uses Docker to orchestrate the local database engine and its peripheral services.

1. Download the installer for your operating system:
* **Windows:** Ensure WSL 2 (Windows Subsystem for Linux) is installed and configured before running the Docker Desktop installer.
* **macOS:** Select the correct version for your chip architecture (Apple Silicon vs Intel).


2. Run the installer and complete the setup wizard.
3. Launch Docker Desktop and verify the daemon is running in the background.

### Step 2: Initialize the Supabase Layout

Navigate to the root directory of your project (`food_files_app`) in your terminal and initialize the configuration:

```bash
mise exec -- supabase init

```

**Output Artifacts:**
This command creates a `/supabase` directory at your project root containing:

* `config.toml`: Holds local infrastructure rules, including JWT secrets, API port mappings, and authentication toggles.
* `/migrations`: Stores SQL migration files to keep database schemas synchronized across the team.

### Step 3: Start the Infrastructure

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