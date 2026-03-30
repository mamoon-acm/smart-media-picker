# Smart Media Field

A highly customizable, all-in-one Flutter widget for picking, compressing, and displaying images and videos. 

It handles the heavy lifting of media selection, loading states, and error handling while giving you complete control over the UI design to match your app's theme.

## Features
* 📸 Pick Images or 🎥 Videos easily.
* 🗜️ Built-in compression and thumbnail generation.
* 🎨 Fully customizable design (colors, borders, icons, text styles).
* 🔄 Handles its own loading and error states.
* 🗑️ Built-in clear/discard functionality.
* 📏 Displays actual file size after compression.

## Platform Setup

Since this package relies on device storage and cameras, you must configure platform-specific permissions.

### Android
No additional configuration is required for standard gallery access on recent Android versions. However, ensure your `android/app/build.gradle` meets the minimum SDK requirements for your project.

### iOS
Add the following keys to your `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your gallery to let you select a profile picture or upload media.</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to let you capture new photos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio with your videos.</string>


### Basic Usage
<!-- SmartMediaField(
  mediaType: MediaType.image,
  buttonText: 'Upload Profile Picture',
  onMediaReady: (SmartMedia media) {
    // Handle your compressed, ready-to-upload file here
    print('Media size: ${media.sizeInMB} MB');
  },
  onClear: () {
    // Handle media removal in your state manager
  },
) -->