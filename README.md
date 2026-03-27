## ⚙️ Setup & Permissions

Since `smart_media_picker` handles native files, camera, and gallery access, you must add the following native permissions to your app.

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml` file, inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### iOS

Add the following keys to your `ios/Runner/Info.plist` file. Without these, your app will crash when trying to open the camera or gallery!

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to the photo library to select media.</string>
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to take photos and videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app requires access to the microphone to record video audio.</string>