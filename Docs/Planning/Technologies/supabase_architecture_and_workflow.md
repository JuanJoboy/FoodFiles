## Why Use the CLI Instead of Developing Directly on the Cloud Dashboard?

While teams can develop directly against the online Supabase dashboard for quick prototypes, doing so in an active multi-developer project introduces severe risks:

1. **Isolated, Destructive Testing:** Testing a bad `DELETE` query, a broken Row Level Security (RLS) policy, or a flawed schema migration on the cloud dashboard corrupts shared data or breaks the live application. Locally, developers can destroy and rebuild the entire database in seconds using `mise run reset`.
2. **Version-Controlled Schema Changes:** Changes made via buttons in the web UI leave no audit trail in the repository. Using the Supabase CLI generates `.sql` migration files inside `supabase/migrations/`, keeping database schemas version-controlled alongside the Flutter codebase.
3. **Zero Latency and Offline Capability:** Cloud queries incur network round-trip latency to remote servers. Local Docker containers respond in under 1 millisecond and allow full-stack development without an internet connection.
4. **No Free-Tier Throttling or Pauses:** Hosted free-tier projects pause after 7 days of inactivity and enforce strict database size and connection caps. Local Docker stacks have zero usage limits.
5. **Unthrottled Auth and Email Testing:** Testing sign-ups and password resets on the cloud quickly exhausts Supabase's strict hourly email rate limits (2-4 emails per hour on the free tier) and clutters real inboxes. The local stack includes **Mailpit**, which intercepts all authentication emails locally with zero rate limits.

In summary: **develop and test locally so the team can reset, experiment, and version-control the backend freely; push migrations to the cloud only after they are verified.**

---

## 1. Local Development vs. Production Cloud Architecture

Food Files uses a split backend architecture: a **local Docker stack** for daily development and a **hosted Supabase Cloud project** for production releases. End users never install Docker or the Supabase CLI on their devices - mobile clients communicate directly over HTTPS with Supabase's cloud infrastructure.

| Layer | Local Development | Production (Published App) |
| :--- | :--- | :--- |
| **Backend Host** | Docker containers on the developer's machine (`192.168.x.x:54321`) | Supabase Cloud (`https://fdadrfbcwzzsysmwfiam.supabase.co`) |
| **Management Interface** | Local Supabase Studio (`http://127.0.0.1:54323`) | Online Supabase Dashboard (`https://supabase.com/dashboard`) |
| **Database Engine** | Local PostgreSQL container (`port 54322`) | Managed Cloud PostgreSQL (`db.fdadrfbcwzzsysmwfiam.supabase.co`) |
| **Email Testing** | Local Mailpit container (`http://127.0.0.1:54324`) | Cloud SMTP / Custom Email Provider |
| **Flutter App Config** | `assets/env` points to the host machine's local IPv4 address | `assets/env` points to the `.supabase.co` URL |
| **Schema Updates** | Applied locally via `mise run reset` | Deployed to cloud via `supabase db push` |

---

## 2. Project Reference & Cloud Credentials

- **Project Reference ID:** `fdadrfbcwzzsysmwfiam`
- **Cloud API URL:** `https://fdadrfbcwzzsysmwfiam.supabase.co`
- **Cloud Publishable Key:** `sb_publishable_2zoSOZ4jVyb5rQdHejFNUA_lw4dA6t4`
- **Direct Postgres Connection:** `postgresql://postgres:[YOUR-PASSWORD]@db.fdadrfbcwzzsysmwfiam.supabase.co:5432/postgres`

> **Security Note:** The Publishable (`anon`) key is safe to bundle inside the compiled Flutter app because database access is governed by Row Level Security (RLS) policies. Never commit database passwords or `Secret` (`service_role`) keys to `assets/env` or any Git-tracked file.

---

## 3. Configuration Files Explained

The repository relies on three separate configuration files. Each serves a distinct tool and must remain separate.

### A. `.mise.toml` (CLI Tool Version & Task Manager)
- **What it is:** Configuration file for `mise` (the team's CLI tool manager).
- **How it works:**
  1. `[tools]` instructs `mise` to install and maintain the latest `supabase` CLI binary (`supabase = "latest"`) without pinning Flutter or Java versions.
  2. `[env]` injects `SUPABASE_URL` into the terminal session automatically when entering the project directory.
  3. `[tasks]` defines standardised task aliases (`mise run up`, `down`, `status`, `reset`) across all developer workstations.
- **Git status:** Tracked in Git so every team member shares identical CLI commands.

### B. `supabase/config.toml` (Local Backend Infrastructure Config)
- **What it is:** The master configuration file for the Supabase CLI and Docker containers. It is independent of `mise`.
- **How it works:** When executing `mise run up` (`supabase start`), the CLI reads `supabase/config.toml` to configure local ports (`54321` for API, `54322` for Postgres, `54323` for Studio, `54324` for Mailpit), JWT expiry settings, storage bucket limits, and third-party OAuth providers (such as Google Sign-In).
- **Handling Secrets:** Because `config.toml` is committed to Git, never hardcode raw OAuth client secrets inside it. Reference environment variables using `env(...)`:

```toml
[auth.external.google]
enabled = true
client_id = "public-client-id"
secret = "env(SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET)"
```

Store the actual secret values inside `supabase/.env` (which is gitignored).

### C. `assets/env` (Flutter Runtime Environment Variables)
- **What it is:** The runtime configuration file loaded by `flutter_dotenv` when the mobile app initialises.
- **How it works:** `lib/main.dart` reads `assets/env` on startup to configure `supabase_flutter` with the target server URL and Publishable key. Switching between local development and production only requires updating the URL and key inside this file.
- **Git status:** Untracked (listed in `.gitignore`). Only `assets/example_env` is committed to Git as a template.

---

## 4. Linking and Deploying to Production

When synchronising local database schemas with the hosted Supabase project or building a release binary, follow these steps.

### Step 1: Authenticate and Link the Repository (One-Time Setup per Machine)
1. Authenticate the local terminal session with Supabase (opens a browser window for verification):
   ```cmd
   mise exec -- supabase login
   ```
2. Link the local `supabase/` directory to the cloud project (only run `supabase init` if the `supabase/` folder does not exist yet):
   ```cmd
   mise exec -- supabase link --project-ref fdadrfbcwzzsysmwfiam
   ```
   *(Provide the remote database password when prompted.)*

### Step 2: Push Local Database Migrations to the Cloud
Whenever tables, functions, or RLS policies are created or modified locally:
1. Generate an SQL migration file capturing the schema changes:
   ```cmd
   mise exec -- supabase db diff -f <migration_name>
   ```
2. Rebuild the local database from scratch to verify the migration applies cleanly:
   ```cmd
   mise run reset
   ```
3. Commit the new file in `supabase/migrations/` to Git, then push the verified migrations to the cloud database:
   ```cmd
   mise exec -- supabase db push
   ```

### Step 3: Switch Flutter From Local to Production
Before building a release APK or App Bundle (`flutter build appbundle`) for distribution:
1. Open `FoodFiles\Frontend\food_files_app\assets\env`.
2. Replace the local host IP (`http://192.168.x.x:54321`) and local publishable key with the production cloud credentials:
   ```env
   SUPABASE_URL=[https://fdadrfbcwzzsysmwfiam.supabase.co](https://fdadrfbcwzzsysmwfiam.supabase.co)
   SUPABASE_ANON_KEY=sb_publishable_2zoSOZ4jVyb5rQdHejFNUA_lw4dA6t4
   ```
3. Compile the release build. Installed builds will communicate directly with the hosted Supabase Cloud instance.

---

## 5. Updating Supabase CLI and Docker Containers

Updating the local backend involves two steps: upgrading the **CLI binary** (via `mise`) and pulling the updated **Docker container images** (Postgres, Studio, GoTrue, Realtime, Storage).

Inside the `Frontend\food_files_app` directory, run the following commands:

```cmd
mise upgrade supabase
mise run down
mise run up
```

Then go into Powershell and run these commands

```powershell
winget upgrade jdx.mise
mise reshim --force
```

###