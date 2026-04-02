import 'dart:io';

enum MediaType { image, video, file }

class SmartMedia {
  /// The final, processed (compressed) file ready for upload.
  final File file;

  /// Whether this is an image or a video.
  final MediaType type;

  /// A generated thumbnail (Only applies if type is MediaType.video).
  final File? thumbnail;

  final double sizeInMb;
  final String? fileName;

  SmartMedia({
    required this.file,
    required this.type,
    required this.sizeInMb,
    this.thumbnail,
    this.fileName,
  });

  /// Helper to check if a thumbnail exists
  bool get hasThumbnail => thumbnail != null;
}
