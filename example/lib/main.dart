import 'package:flutter/material.dart';
import 'package:smart_media_picker/smart_media_picker.dart'; // Make sure this import matches your library export!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Media Picker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variables to hold the selected media
  SmartMedia? _profileImage;
  SmartMedia? _promoVideo;

  void _submitData() {
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image first!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success! Image size: ${_profileImage!.sizeInMb.toStringAsFixed(2)} MB',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Smart Media Picker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 1. Basic Image Picker
            SmartMediaField(
              mediaType: MediaType.image,
              buttonText: 'Upload Photo',
              height: 200,
              onMediaReady: (media) {
                setState(() => _profileImage = media);
              },
              onClear: () {
                setState(() => _profileImage = null);
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Promo Video (Custom Styled)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 2. Custom Styled Video Picker
            SmartMediaField(
              mediaType: MediaType.video,
              buttonText: 'Select Short Video',
              height: 160,
              backgroundColor: Colors.purple.shade50,
              borderColor: Colors.purple.shade200,
              iconColor: Colors.purple,
              emptyIcon: Icons.video_library_rounded,
              borderRadius: 16,
              clearIconColor: Colors.redAccent,
              onMediaReady: (media) {
                setState(() => _promoVideo = media);
              },
              onClear: () {
                setState(() => _promoVideo = null);
              },
            ),

            const SizedBox(height: 32),
            const Text(
              'Document Upload (PDFs, etc.)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SmartMediaField(
              mediaType: MediaType.file, // Test the new file type!
              buttonText: 'Select Resume or Document',
              height: 120,
              allowFiles: true,

              emptyIcon: Icons.file_present,
              backgroundColor: Colors.orange.shade50,
              borderColor: Colors.orange.shade200,
              iconColor: Colors.orange,
              onMediaReady: (media) {
                print('File Selected: ${media.fileName}');
                // Handle the file...
              },
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitData,
                child: const Text('Submit Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
