# Instagram Feed Clone (Flutter)

A highly polished, visually identical replication of the current Instagram Home Feed built with Flutter.

## Features Let's Review
- **Pixel-Perfect UI**: Matches the top bar, Stories tray, and post feed perfectly.
- **Advanced Media Handling**: 
  - Carousel for posts with multiple images using `PageView` and custom dot indicators.
  - **Pinch-to-Zoom** interactive scaling of images over the UI that automatically snaps back on release.
- **Stateful Interactions**: Contextual UI switching for Like and Bookmark features using strict state immutability.
- **Graceful Error Handling**: SnackBar popups for unimplemented mock functionality.
- **Network Simulation**: 
  - 2.2 seconds mock latency for fetching API responses.
  - Elegant `Shimmer` skeleton loader for the initial empty feed state.
- **Infinite Scroll**: "Lazy loading" trigger fetch of 10 new posts when user is close to the bottom.

## Architecture & State Management

This project uses **Riverpod** (`flutter_riverpod`) for state management. 

### Why Riverpod?
- **Compile-Safe Dependencies**: The entire widget tree safely depends on our `FeedNotifier` without the risks of classic `Provider` finding an incorrect context.
- **Easy Asynchrony handling**: Binding the state asynchronously inside `AsyncValue` inherently manages Loading (`Shimmer`), Error, and Data states without tedious boilerplate.
- **Immutability & Predictability**: Our `Post` state models are completely immutable and new updates simply copy over the old class instance, ensuring predictable renders across deeply nested Widgets (like our `PostWidget`).

### Separation of Concerns
- **`/models`**: Immutable application entities (`User`, `Post`).
- **`/repositories`**: Simulated data services mirroring real network abstractions.
- **`/providers`**: The binding glue (Notifier) managing transitions between requests and caching data reliably.
- **`/widgets` and `/screens`**: Pure UI layout trees observing Riverpod state.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK

### Installation
1. Clone the repository: `git clone <YOUR_REPO_URL>`
2. Fetch dependencies: 
   ```bash
   flutter pub get
   ```
3. Run the project:
   ```bash
   flutter run
   ```

*(Tested on Android and web)*
