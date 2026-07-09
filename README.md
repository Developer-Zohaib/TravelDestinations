# TravelDestinations

A polished SwiftUI travel discovery app built as a portfolio-quality demo of modern iOS architecture, media-heavy UI, custom caching, MapKit, AVKit playback, and sticker creation workflows.

The project started as a travel destination browser and has evolved into a richer app shell that can support production-style features: remote content, image caching, pull-to-refresh without data flicker, custom video playback, destination maps, and an iMessage sticker extension.

## Overview

**TravelDestinations** lets users explore curated destinations, view rich detail pages, browse destination maps, watch cinematic travel videos, and create shareable travel stickers from destination imagery.

The app demonstrates SwiftUI-first screen composition, Firestore-backed metadata, externally hosted media URLs, a custom async image pipeline with memory and disk caching, view-state driven loading/error handling, MapKit, AVFoundation/AVKit, Sticker Studio, and an iMessage sticker extension.

## Features

- Browse destinations with list, grid, and full-width image modes
- Stable navigation using `NavigationStack` and `navigationDestination`
- Pull-to-refresh that preserves existing content while refreshing
- Destination detail pages with hero imagery, overview, facts, gallery, map preview, and external links
- Custom `ImagePipeline` actor with memory cache, disk cache, and request de-duplication
- Image reuse across browse, detail, map pins, and sticker workflows
- Custom `AVPlayer` video player with autoplay, play/pause, seek bar, timestamps, and 10-second skip controls
- Loading, buffering, retry, and error states for hosted video streams
- MapKit destination map with custom image-based annotations
- Sticker Studio with single-sticker and destination-pack modes
- Swipeable sticker image selection using main and gallery images
- Sticker export through the native share sheet
- Toast feedback for export outcomes
- Dedicated iMessage sticker extension
- Centralized `AppTheme`, branded gradients, shared loading views, and reusable headers

## Screenshots

<img width="200" src="https://github.com/user-attachments/assets/779fe05a-a227-4c44-92d6-692539fc9b99" />
<img width="200" src="https://github.com/user-attachments/assets/bcef5fd7-8c92-4262-8969-c1bd343f47a9" />
<img width="200" src="https://github.com/user-attachments/assets/a98e8f37-aa38-4757-8fe7-2adbad54905c" />
<img width="200" src="https://github.com/user-attachments/assets/dbf05a02-b834-442b-8a5f-24449e84146e" />
<img width="200" src="https://github.com/user-attachments/assets/12471fe1-5830-49c6-8a8a-d32bbbe464d7" />
<img width="200" src="https://github.com/user-attachments/assets/07676467-9228-4c41-a671-660e4d063437" />
<img width="200" src="https://github.com/user-attachments/assets/c490e6ba-5bac-4d1d-8fa4-e79f10e7ea3d" />
<img width="200" src="https://github.com/user-attachments/assets/865cd656-fea6-4930-adc9-34a5580d8482" />
<img width="200" src="https://github.com/user-attachments/assets/ea7c8374-150c-47f0-a40a-27465a1a0d85" />
<img width="200" src="https://github.com/user-attachments/assets/9c03a5d8-040a-456a-a062-9ed5009f256f" />


**[Watch Demo Video](https://github.com/user-attachments/assets/d7119b94-9955-4124-9e9f-02ce04024c9b)
## Architecture

The app uses a pragmatic SwiftUI architecture with clear separation between models, networking, screen views, reusable UI components, and platform integrations.

Key pieces:

- `FirestoreService`: generic Firestore fetching and shared `ViewState`
- `ImagePipeline`: actor-isolated image loading with memory/disk caching
- `DemoImageProvider`: hosted media URL resolution and fallback image handling
- `VideoPlayerController`: AVPlayer ownership, playback state, autoplay, seek, retry, and progress tracking
- `AppTheme`: centralized colors, gradients, loading components, and appearance setup

## Data And Media

The app supports Firestore for structured metadata such as destination names, facts, coordinates, video entries, and gallery references.

Media is expected to come from externally hosted URLs:

- Images should be direct, cacheable image URLs.
- Videos should be direct MP4 URLs.
- For best iOS playback, videos should be encoded as `H.264 + AAC`, support byte-range requests, and be served with `Content-Type: video/mp4`.

This avoids relying on Firebase Storage free-plan availability while keeping the app flexible for any hosting provider.

## Technologies

- Swift 5
- SwiftUI
- Async/await
- Firebase Firestore
- MapKit
- AVFoundation / AVKit
- Messages framework
- UIKit bridges where needed
- Custom image caching
- Native share sheet export

## Getting Started

1. Clone the repository:

   `git clone https://github.com/Developer-Zohaib/TravelDestinations.git`

2. Open the project in Xcode.

3. Add your Firebase configuration if using Firestore:

   `GoogleService-Info.plist`

4. Make sure your Firestore documents point to valid hosted image/video URLs.

5. Select the `Travel Destinations` scheme and run on an iOS simulator or device.

For the iMessage sticker extension, run the `Travel Stickers MessagesExtension` target or install the main app on a device/simulator with Messages available.

## Portfolio Highlights

This project is intended to demonstrate senior-level iOS practices in a compact demo:

- Resilient UI state management instead of scattered loading booleans
- Cache-aware media loading without third-party image dependencies
- Lazy navigation and stable SwiftUI identity handling
- Graceful refresh behavior that avoids clearing visible data unnecessarily
- Native platform integrations that go beyond a basic CRUD demo
- A realistic path from demo code toward an enterprise-ready app foundation

## Contributing

Have ideas for improvements or found a bug? Feel free to open an issue or create a pull request.

## Acknowledgements

This app was created as part of my ongoing journey mentoring iOS development and exploring best practices in SwiftUI, native Apple frameworks, and scalable app architecture.

## Connect With Me

- LinkedIn: https://www.linkedin.com/in/zohaib-afzal-526859160/
- GitHub: https://github.com/Developer-Zohaib
- Email: developer.zohaibafzal@gmail.com

If you found this project helpful, please give it a star and share it with others.
