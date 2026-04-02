# Smart Media Field

A highly customizable, all-in-one Flutter widget for picking, compressing, and displaying images and videos. 

It handles the heavy lifting of media selection, loading states, and error handling while giving you complete control over the UI design to match your app's theme.

## Features
* 📸 Pick Images, 🎥 Videos, or 📄 Documents (PDFs, Docs, etc.) seamlessly.
* 🎨 Fully customizable UI (tweak colors, borders, icons, and text).
* 📱 **Smart Bottom Sheet:** Automatically adapts options based on the requested media type.
* 🗜️ Built-in compression and video thumbnail generation.
* 📏 Automatic file-size overlay and validation.
* ♻️ Handles its own loading, error, and clear states out of the box.

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


## Basic Usage

### 1. Image or Video Picker
By default, the widget allows users to pick an image from their camera or gallery.
```dart
SmartMediaField(
  mediaType: MediaType.image,
  buttonText: 'Upload Profile Picture',
  onMediaReady: (SmartMedia media) {
    print('Image size: ${media.sizeInMb} MB');
  },
)


### 2. Document Picker
To specifically ask for a document (like a PDF or Resume), set the mediaType to file. You can also restrict exactly which extensions are allowed!
```dart
  SmartMediaField(
      mediaType: MediaType.file,
       buttonText: 'Select Resume (PDF/DOC)',
         allowedExtensions: const [
           'pdf',
           'doc',
           'docx',
        ], // Restrict file types
        onMediaReady: (SmartMedia media) {
          print('Selected File: ${media.fileName}');
        },
    ),