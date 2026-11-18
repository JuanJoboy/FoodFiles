# Software Requirements Specification (SRS)

## 1. Document Conventions

This document defines the functional requirements, non-functional requirements, and use cases for the **Food Files** mobile application. All requirements and use cases are partitioned into numeric series corresponding to distinct functional domains:

### 1.1 Scope Exclusions

* **OAuth Providers:** Authentication via Microsoft, Apple, and Facebook is explicitly excluded from this release.
* **Friends:** Communicating with users, and sharing posts to users will not be added.

### 1.2 Requirement Domains

| Series | Domain |
| --- | --- |
| **100** | Login |
| **200** | Following Feed & Social Interactions |
| **300** | Map Discovery & Post Creation |
| **400** | Public Explore & Filtering |
| **500** | User Profile, Social Graph & Content Organisation |
| **600** | Settings, Privacy & Legal Governance |
| **700** | System-Wide, Cross-Platform & Infrastructure |

### 1.3 Priority Matrix

Requirements are grouped by related functionality and categorised by MoSCoW necessity, business value, and a calculated priority score within each functional domain. Within each domain, requirements are ordered primarily by MoSCoW necessity (Must Have to Won't Have) and secondarily by Business Value (Core to Supporting).

To ensure consistent categorisation, each requirement is assigned a MoSCoW rating based on its alignment with the project scope and its requirement phrasing (`must`, `should`, `could`, or `won't`). In decreasing order of necessity, the MoSCoW ratings are:

| MoSCoW Rating | Weight | Description |
| --- | --- | --- |
| **Must Have** | 4 | Features essential to Food Files' minimum viable functionality. Releasing Food Files without these requirements implemented would render the application unusable. |
| **Should Have** | 3 | Important features that add significant utility to Food Files and are expected to be implemented once all Must Have requirements are delivered without excessive delays. |
| **Could Have** | 2 | Quality-of-life enhancements that improve the user experience. |
| **Won't Have** | 1 | Features explicitly excluded from the current development period, retained as potential additions for future iterations of Food Files. |

<br>

To measure the business impact of each requirement, three business value tiers are defined:

| Business Value | Weight | Description |
| --- | --- | --- |
| **Core** | 3 | Foundational requirements for the basics of a social network mobile application. |
| **Proprietary** | 2 | Differentiating Food Files features that are unique to the app and enhance the food tracking experience. |
| **Supporting** | 1 | Supplementary features that enhance user satisfaction, without being strictly required for core operation. |

<br>

To systematically prioritise requirements, the MoSCoW weight is multiplied by the Business Value weight to produce a numerical priority score (`Priority = MoSCoW x Business Value`). For example, a requirement classified as **Must Have** (4) and **Core** (3) receives a priority score of `12`.

| MoSCoW \ Business Value | Core (3) | Proprietary (2) | Supporting (1) |
| --- | --- | --- | --- |
| **Must Have (4)** | 12 | 8 | 4 |
| **Should Have (3)** | 9 | 6 | 3 |
| **Could Have (2)** | 6 | 4 | 2 |
| **Won't Have (1)** | 3 | 2 | 1 |

<br>

In descending order of precedence, the twelve priority combinations rank as follows:

| Rank | Priority Score | Combination |
| --- | --- | --- |
| 1 | **12** | Must Have x Core |
| 2 | **9** | Should Have x Core |
| 3 | **8** | Must Have x Proprietary |
| 4 | **6** | Should Have x Proprietary |
| 5 | **6** | Could Have x Core |
| 6 | **4** | Must Have x Supporting |
| 7 | **4** | Could Have x Proprietary |
| 8 | **3** | Should Have x Supporting |
| 9 | **3** | Won't Have x Core |
| 10 | **2** | Could Have x Supporting |
| 11 | **2** | Won't Have x Proprietary |
| 12 | **1** | Won't Have x Supporting |

---

## 2. Functional Requirements

### 2.1 Login

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **FR-101** | Google OAuth Sign-In | The system must allow users to register and authenticate using a Google account via OAuth 2.0. | Must Have | Core | 12 |
| **FR-102** | Email & Password Authentication | The system must allow users to register and sign in using a standard email address and password credential pair. | Must Have | Core | 12 |

### 2.2 Following Feed & Social Interactions

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **FR-201** | Following Feed Aggregation | The home feed must display a vertically scrollable list of posts authored exclusively by accounts in the authenticated user's Following List, as well as posts that the user has made. | Must Have | Core | 12 |
| **FR-202** | Post Engagement Controls | Each post card must provide interactive controls to Like, Comment, and Favourite the post. | Must Have | Core | 12 |
| **FR-203** | Categorised Favourite Collections | Tapping the Favourite button must allow users to save the post into named, user-created collections (TikTok-style bookmarking). | Must Have | Core | 12 |
| **FR-204** | Direct Comment Navigation | Tapping the Comment icon on a feed card must open the Comment Section. | Must Have | Core | 12 |
| **FR-205** | Text & Emoji Comment Constraint | The comment input field and renderer must accept standard Unicode text and emojis only, rejecting image, video, audio, or file attachments. | Must Have | Core | 12 |
| **FR-206** | Feed Description Truncation | Post descriptions exceeding the feed card preview height should truncate with a vertical gradient fade-out effect rather than expanding the card height. | Should Have | Core | 9 |
| **FR-207** | Detailed Post View | Tapping a post's description body should navigate to the dedicated Post Detail view, rendering the full description inside a fixed-height, internally scrollable container. | Should Have | Core | 9 |
| **FR-208** | Liking | The Like Button should influence the priority that a post is shown when displaying public posts in the Explore Feed. | Should Have | Core | 9 |

### 2.3 Map Discovery & Post Creation

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **FR-301** | Interactive Map POI Selection | Tapping a venue on the map must extract its canonical Restaurant Name and Suburb/Location (e.g., `McDonald's, Cannington`) and advance the user to the post entry form. | Must Have | Core | 12 |
| **FR-302** | Immutable Venue Data | Once parsed from the map, the `Restaurant` and `Location` fields must be locked as read-only (immutable) for that post. | Must Have | Core | 12 |
| **FR-303** | Mandatory Meal Data | The post creation form must enforce required input for the: `Date`, `Title`, `Food`, `Description`, `Rating` (numeric scale out of 10), and `Post Visibility` (`Public`, `Friends Only`, or `Unlisted`). | Must Have | Core | 12 |
| **FR-304** | Optional Meal Data | The post creation form must permit optional input for `Time` of meal and `Picture` (captured live via device camera or selected from the local photo gallery). If no `Time` is submitted, then it takes in the current time. | Must Have | Core | 12 |
| **FR-305** | Conditional Pricing & Discount Logic | If the post is marked as **not discounted**, standard `Price` is required and `Discounted Price` is omitted. If marked as **discounted**, `Discounted Price` is required as well as the original `Price`. | Must Have | Core | 12 |
| **FR-306** | Post Format | A post must show the description and other text on the first slide, and the picture on the next slide. This carousel must also be infinitely scrollable horizontally. | Must Have | Core | 12 |
| **FR-307** | Automatic Current Location Focus | Upon opening the Post Creation map, the viewport must immediately centre on the user's current GPS coordinates if device location permissions are granted. Otherwise it must be zoomed out and show the Earth. | Must Have | Proprietary | 8 |
| **FR-308** | Proximity Place Search | The map interface must include a search bar that has geocoding autocomplete and queries nearby venues and points of interest (POIs) matching user text input, replicating Google Maps autocomplete and proximity ranking. | Must Have | Proprietary | 8 |
| **FR-309** | Tri-Axis Meal Triangle | The post creation form must provide an interactive 3-vertex triangle control allowing users to balance and record relative scores across `Nutrition`, `Satisfaction / Enjoyment`, and `Price`. | Must Have | Proprietary | 8 |
| **FR-310** | Circadian Map Lighting | The map renderer must dynamically adjust lighting and colour palettes to reflect the user's local time of day (e.g., applying a warm dusk aesthetic around 18:00 local time). | Must Have | Supporting | 4 |
| **FR-311** | Text Modifiers | Text modifiers for the description must be available such as *italicizing*, **bolding**, etc. | Must Have | Supporting | 4 |

### 2.4 Public Explore & Filtering

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **FR-401** | Public Account Explore Feed | The Explore page must aggregate and display posts from any user whose account privacy is set to `Public` and whose individual post visibility is set to `Public`. | Must Have | Core | 12 |
| **FR-402** | Multi-Faceted Explore Filters | The Explore page should allow users to filter displayed posts by `Date`, `Restaurant`, `Food`, `Price`, `Rating`, and secondary data attributes. | Should Have | Proprietary | 6 |

### 2.5 User Profile, Social Graph & Content Organisation

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **FR-501** | Profile Header | The Profile page must display the user's display name, profile picture, total post count, follower count, following count, biography text, and posts. | Must Have | Core | 12 |
| **FR-502** | Profile Attribute Editing | Users must be able to edit their own `Username`, `Profile Picture`, and `Bio`. | Must Have | Core | 12 |
| **FR-503** | Account Follow Mechanism | Users must be able to follow and unfollow other accounts from their profile pages. | Must Have | Core | 12 |
| **FR-504** | Tab 1 - Hierarchical Post Folders | The first profile gallery tab must organise all user posts into a nested directory hierarchy: `Restaurant -> Location -> Post`. | Must Have | Proprietary | 8 |
| **FR-505** | Tab 2 - Custom Post Lists | The second profile gallery tab must allow users to create and view curated lists containing a required `List Name`, optional `Description`, required list of `Posts`, and required `Visibility` (`Public`, `Friends Only`, or `Unlisted`). | Must Have | Proprietary | 8 |
| **FR-506** | Tab 3 - Structured Eatlist | The third profile gallery tab must provide users with a food watchlist (*"Eatlist"*) allowing users to log desired meals organised strictly as `Restaurant -> Location -> Food`. | Must Have | Proprietary | 8 |
| **FR-507** | Tab 4 - Categorised Favourites Gallery | The fourth profile gallery tab must display all posts saved by the user, grouped by their assigned Favourite collections. | Must Have | Proprietary | 8 |
| **FR-508** | Editable Restaurant Folder Names | Top-level restaurant folders must default to the parsed restaurant name but allow the user to rename the folder label without mutating the underlying post. | Must Have | Supporting | 4 |
| **FR-509** | Contextual Location Quick-Post | Inside any `Location` folder view, a floating `+` button (bottom-right corner) must launch the Post Creation form with `Restaurant` and `Location` pre-populated and locked. | Must Have | Supporting | 4 |
| **FR-510** | PNG Post Export | Users should be able to render and download any post card as a standalone `.png` image file to their device storage. | Should Have | Proprietary | 6 |

### 2.6 Settings, Privacy & Legal Governance

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **FR-601** | Password Reset Workflow | The Settings menu must provide a password reset flow allowing email/password users to update their credentials. | Must Have | Core | 12 |
| **FR-602** | Global Account Privacy Toggle | The Settings menu must allow users to switch their account status between `Public` and `Private`. | Must Have | Core | 12 |
| **FR-603** | Legal Policy Documents | The About section within Settings must render or link to the active `Privacy Policy` and `Terms of Use` hosted and managed via FlyCricket (`[https://app.flycricket.com/documents/policies/manage](https://app.flycricket.com/documents/policies/manage)`). | Must Have | Supporting | 4 |
| **FR-604** | Device Permission Status & Routing | The Settings menu should display current permission states and link to OS settings for `Location`, `Camera & Microphone`, and `Photos & Videos`. | Should Have | Supporting | 3 |

---

## 3. Non-Functional Requirements

| ID | Title | Description | MoSCoW | Business Value | Priority |
| --- | --- | --- | --- | --- | --- |
| **NFR-201** | Feed Rendering Performance | The Following and Explore feeds must maintain smooth 60 FPS scrolling while loading paginated posts and gradient text overlays. | Must Have | Core | 12 |
| **NFR-202** | Layout Stability | Opening a post description must not trigger layout shifts in parent containers; overflow text must remain bounded inside the fixed scrollable viewport. | Must Have | Core | 12 |
| **NFR-301** | Map Initialisation Latency | When location permissions are granted, the map viewport must resolve GPS coordinates and render tiles within 2 seconds of screen mount. | Must Have | Proprietary | 8 |
| **NFR-302** | Better Map UI | The map POI tap-to-post interaction should present clear visual signifiers (e.g., instructional prompts, pin highlights, or pulsing indicators) so first-time users immediately understand how to initiate a post. | Should Have | Proprietary | 6 |
| **NFR-401** | Search & Filter Responsiveness | Applying or clearing filters on the Explore page must return updated query results within 3 second under normal network conditions. | Must Have | Proprietary | 8 |
| **NFR-501** | Privacy Enforcement | Posts marked `Unlisted` or `Friends Only`, as well as posts belonging to `Private` accounts, must be strictly enforced at the database Row Level Security (RLS) layer so unauthorised clients cannot query them via API. | Must Have | Core | 12 |
| **NFR-701** | Cross-Platform Parity | The application must compile, render, and function identically on both **iOS** and **Android** mobile operating systems from a single Flutter codebase. | Must Have | Supporting | 4 |

---

## 4. Use Cases

### UC-101: Login

* **Actors:** Unauthenticated User, Google OAuth Provider, Supabase Auth
* **Linked FRs:** `FR-101`, `FR-102`
* **Linked NFRs:** `NFR-701`
* **Preconditions:** User has installed the app on iOS or Android and is not currently signed in.
* **Main Flow:**

1. System displays the login screen framed by top and bottom burger bun graphics.
2. User selects either **Continue with Google** (`FR-101`) or enters an email and password (`FR-102`).
3. System validates credentials against the authentication backend.
4. System establishes an authenticated session and routes the user to the Following Feed.

* **Alternative Flows:**
* *A1 (Invalid Credentials):* System displays an inline authentication error and retains the user on the login screen.
* **Postconditions:** User holds a valid session token and can access protected routes.

---

### UC-201: Browse Following Feed & Engage With Posts

* **Actors:** Authenticated User
* **Linked FRs:** `FR-201`, `FR-202`, `FR-203`, `FR-204`, `FR-205`, `FR-206`, `FR-207`
* **Linked NFRs:** `NFR-201`, `NFR-202`, `NFR-701`
* **Preconditions:** User follows at least one account with posts or has posts of their own.
* **Main Flow:**

1. System queries posts from followed accounts or themselves (`FR-201`).
2. User scrolls through posts; long descriptions fade out smoothly at the card boundary (`FR-206`, `NFR-201`).
3. User taps the **Like** button to toggle like state (`FR-202`).
4. User taps the **Favourite** button, creates a new collection (e.g., "Perth Burgers"), and saves the post (`FR-202`, `FR-203`).
5. User taps the faded description body to open the Post Detail view (`FR-207`).
6. User scrolls inside the fixed-height description container to read the full review without expanding the layout (`FR-207`, `NFR-202`).
7. User enters a text and emoji comment in the section directly below and submits (`FR-205`).

* **Alternative Flows:**
* *A1 (Direct Comment Jump):* User taps the Comment icon directly on the feed card; the system opens the Comment Section (`FR-202`, `FR-204`).
* **Postconditions:** Likes, favourite collection mappings, and comments are persisted to the backend.

---

### UC-301: Discover Venue on Map & Create Meal Post

* **Actors:** Authenticated User
* **Linked FRs:** `FR-301`, `FR-302`, `FR-303`, `FR-304`, `FR-305`, `FR-306`, `FR-307`, `FR-308`, `FR-309`, `FR-310`, `FR-311`
* **Linked NFRs:** `NFR-301`, `NFR-302`, `NFR-701`
* **Preconditions:** User opens the Create Post section.
* **Main Flow:**

1. System checks location permissions, centres the map on the user's current GPS position (`FR-307`, `NFR-301`), and applies time-of-day lighting (`FR-310`).
2. Visual cues prompt the user to tap a restaurant on the map (`NFR-302`).
3. User searches for a nearby venue via the search bar (`FR-308`) or pans the map, then taps the venue pin.
4. System parses the venue name and suburb (`McDonald's, Cannington`) and opens the post form with those fields locked (`FR-301`, `FR-302`).
5. User enters `Date`, `Title`, `Food`, `Description` (with optional text modifiers), `Rating`, and `Visibility` (`FR-303`, `FR-311`), plus optional `Time` and `Picture` (`FR-304`).
6. User toggles `Discounted` off and enters a required `Price` (`FR-305`).
7. User adjusts the 3-point triangle across `Nutrition`, `Satisfaction / Enjoyment`, and `Price` (`FR-309`).
8. User submits the form; the post is published and automatically filed under `Restaurant -> Location` in their profile (`FR-306`).

* **Alternative Flows:**
* *A1 (Discounted Meal):* User toggles `Discounted` on; `Discounted Price` becomes mandatory as well as the original `Price` (`FR-305`).
* *A2 (Location Permission Denied):* Map loads with the zoomed out Earth in frame (`FR-307`).
* **Postconditions:** New meal post is stored with immutable venue tags and is visible according to its visibility setting.

---

### UC-401: Discover & Filter Public Posts on Explore

* **Actors:** Authenticated User
* **Linked FRs:** `FR-208`, `FR-401`, `FR-402`
* **Linked NFRs:** `NFR-201`, `NFR-401`, `NFR-501`, `NFR-701`
* **Preconditions:** Public accounts have published public posts.
* **Main Flow:**

1. User navigates to the Explore tab.
2. System loads a feed of public posts from public accounts that are shown in the order of the highest liked posts being first (`FR-208`, `FR-401`, `NFR-501`).
3. User opens the filter drawer and applies criteria for `Restaurant`, `Price` range, and minimum `Rating` (`FR-402`).
4. System updates the Explore feed to display matching posts (`NFR-401`).

* **Postconditions:** Filtered public posts are displayed to the user.

---

### UC-501: Organise Profile Folders, Lists, Eatlist & Favourites

* **Actors:** Authenticated User
* **Linked FRs:** `FR-501`, `FR-502`, `FR-503`, `FR-504`, `FR-505`, `FR-506`, `FR-507`, `FR-508`, `FR-509`, `FR-510`, `FR-511`, `FR-512`
* **Linked NFRs:** `NFR-501`, `NFR-701`
* **Preconditions:** User is viewing their profile page.
* **Main Flow:**

1. System renders profile statistics (posts, followers, following) and bio (`FR-501`).
2. In **Tab 1 (Folders)**, user navigates `Restaurant -> Location -> Post` (`FR-504`), renames a restaurant folder (`FR-508`), and taps the bottom-right `+` button inside a Location folder to create a new post pre-filled with that venue (`FR-509`).
3. In **Tab 2 (Custom Lists)**, user creates a `Public` list with a name, description, and selected posts (`FR-505`).
4. In **Tab 3 (Eatlist)**, user adds a desired food item under `Restaurant -> Location -> Food` (`FR-506`).
5. In **Tab 4 (Favourites)**, user browses saved posts organised by collection (`FR-507`).

* **Alternative Flows:**
* *A1 (Viewing Another User):* Edit controls and private tabs/lists are hidden (`NFR-501`), and a Follow/Unfollow button is presented (`FR-503`).
* **Postconditions:** Profile data, custom lists, folder labels, and eatlist items are saved.

---

### UC-601: Manage Account Settings, Permissions & Legal Policies

* **Actors:** Authenticated User
* **Linked FRs:** `FR-601`, `FR-602`, `FR-603`, `FR-604`
* **Linked NFRs:** `NFR-501`, `NFR-701`
* **Preconditions:** User opens Settings from their Profile page.
* **Main Flow:**

1. User toggles Account Privacy from `Public` to `Private` (`FR-602`), restricting future post visibility on the Explore feed (`NFR-501`).
2. User checks permission statuses for `Location`, `Camera & Microphone`, and `Photos & Videos` (`FR-604`).
3. User opens the About section and views the `Privacy Policy` and `Terms of Use` (`FR-603`).

* **Alternative Flows:**
* *A1 (Password Reset):* User triggers a password reset request from Settings (`FR-601`).
* **Postconditions:** Updated privacy settings and credentials are applied to the user's account.

---

## 5. Requirements Traceability Matrix

| Use Case ID | Use Case Title | Linked Functional Requirements | Linked Non-Functional Requirements |
| --- | --- | --- | --- |
| **UC-101** | Login | `FR-101`, `FR-102` | `NFR-701` |
| **UC-201** | Browse Following Feed & Engage With Posts | `FR-201`, `FR-202`, `FR-203`, `FR-204`, `FR-205`, `FR-206`, `FR-207` | `NFR-201`, `NFR-202`, `NFR-701` |
| **UC-301** | Discover Venue on Map & Create Meal Post | `FR-301`, `FR-302`, `FR-303`, `FR-304`, `FR-305`, `FR-306`, `FR-307`, `FR-308`, `FR-309`, `FR-310`, `FR-311` | `NFR-301`, `NFR-302`, `NFR-701` |
| **UC-401** | Discover & Filter Public Posts on Explore | `FR-208`, `FR-401`, `FR-402` | `NFR-201`, `NFR-401`, `NFR-501`, `NFR-701` |
| **UC-501** | Organise Profile Folders, Lists, Eatlist & Favourites | `FR-501`, `FR-502`, `FR-503`, `FR-504`, `FR-505`, `FR-506`, `FR-507`, `FR-508`, `FR-509`, `FR-510`, `FR-511`, `FR-512` | `NFR-501`, `NFR-701` |
| **UC-601** | Manage Account Settings, Permissions & Legal Policies | `FR-601`, `FR-602`, `FR-603`, `FR-604` | `NFR-501`, `NFR-701` |