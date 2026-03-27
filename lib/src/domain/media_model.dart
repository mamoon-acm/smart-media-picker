import 'dart:io';

enum MediaType { image, video }

class SmartMedia {
  /// The final, processed (compressed) file ready for upload.
  final File file;

  /// Whether this is an image or a video.
  final MediaType type;

  /// A generated thumbnail (Only applies if type is MediaType.video).
  final File? thumbnail;

  /// The final size of the file in bytes. Useful for UI feedback.
  final int sizeInBytes;

  SmartMedia({
    required this.file,
    required this.type,
    required this.sizeInBytes,
    this.thumbnail,
  });

  /// A handy helper to get the size in Megabytes for UI display
  double get sizeInMB => sizeInBytes / (1024 * 1024);

  /// Helper to check if a thumbnail exists
  bool get hasThumbnail => thumbnail != null;
}
