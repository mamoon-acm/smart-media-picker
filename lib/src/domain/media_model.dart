import 'dart:io';

/// Unified data class for picked media files.
class MediaModel {
  final File file;
  final String fileName;
  final String? extension;
  final Duration? duration; // For video files
  final int? fileSize;

  const MediaModel({
    required this.file,
    required this.fileName,
    this.extension,
    this.duration,
    this.fileSize,
  });
}
