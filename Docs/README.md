# Food Files

Food Files is a cross-platform mobile application for iOS and Android built for logging, rating, and discovering meals eaten out at restaurants, cafes, and fast-food venues. It combines the visual feed of a social network with structured personal cataloguing and interactive map discovery.

---

## The Problem It Solves

Tracking where you eat and what you order is currently fragmented across tools that were not built for the job:

- **General Social Media (Instagram, TikTok):** Food posts are mixed in alongside other unrelated content, and posts that are related to food can't be easily filtered by price, rating, suburb, or specific menu items, making it difficult when deciding where to eat.
- **Notes Apps:** Writing down food reviews in a personal notes app keeps data private but unstructured. Notes is simple for writing down reviews, however Food Files provides a map integration, visual galleries, and an easy way to share recommendations.
- **Public Review Platforms (Google Maps, Yelp):** Existing review platforms focus on overall venue service rather than individual menu items. They force all logs to be public and do not provide personal folder hierarchies or wishlists for dishes you plan to try.

Food Files consolidates these workflows into a single platform dedicated strictly to food logging and discovery.

---

## What It Is Similar To

| Platform | Shared Concept in Food Files |
| :--- | :--- |
| **Letterboxd / Goodreads** | Personal logging, numerical ratings (out of 10), curated custom lists, and a dedicated watchlist ("Eatlist") for future meals. |
| **Instagram** | Chronological following feeds, photo carousels, user profiles, and saveable bookmark collections. |
| **Google Maps** | Location-first discovery, proximity search, and pinning exact establishments to verify where a meal took place. |

---

## Why Use Food Files

- **Exact Recall:** Never forget what you ordered at a specific restaurant branch six months ago, how much it cost, or whether it was worth the money.
- **Verified Locations:** Tapping a venue directly on the built-in map locks the restaurant name and suburb into the post, eliminating misspelled venue names and duplicate entries.
- **Granular Value Tracking:** Beyond a standard score out of 10, posts capture exact pricing, discounts, and a three-point balance triangle measuring **Nutrition**, **Satisfaction**, and **Price**.
- **Flexible Privacy:** Keep logs completely private as a personal food diary, restrict them to friends, or publish them to the public Explore feed.

---

## How to Use Food Files

### 1. Log a Meal via the Map
1. Open the post creation map, which centres on your current GPS location and adjusts its lighting to match the local time of day.
2. Search for an establishment or tap a venue pin directly on the map (for example, `McDonald's, Cannington`).
3. Enter in the details of the dish, a description of what you thought of it, and set a rating.
4. Adjust the post visibility and post it.

### 2. Organise Your Profile Archive
Your profile automatically structures your food history into dedicated tabs:
- **Folders:** Every post is automatically filed under `Restaurant -> Location -> Post`, allowing you to view every visit to a specific branch in one place.
- **Custom Lists:** Group posts into themed lists (such as "Best Burgers Under $15" or "Late Night Feeds") to keep private or share publicly.
- **Eatlist:** Maintain a structured watchlist of dishes you want to try, organised by `Restaurant -> Location -> Food`.
- **Favourites:** Save posts into custom bookmark collections.

### 3. Discover What to Eat Next
- **Following Feed:** Scroll through recent meals logged by people you follow to see honest reviews from friends rather than sponsored content.
- **Explore Page:** Browse high-rated public posts across the platform and filter results by restaurant, specific dish, price range, or rating.

---

## Technical Stack

- **Frontend:** Flutter (Dart) targeting iOS and Android
- **Backend & Auth:** Supabase, PostgreSQL
- **Maps & Geocoding:** Mapbox SDK

---

## Setup
- To get setup, please read the [following guide](Setup\setup.md)