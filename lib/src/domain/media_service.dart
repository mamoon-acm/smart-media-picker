import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart'; // Added File Picker import

import '../core/exceptions.dart';
import '../core/media_config.dart';
import 'media_model.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  /// Main entry point to pick and process image/video media
  Future<SmartMedia> pickMedia({
    required MediaType type,
    required ImageSource source,
    required MediaConfig config,
  }) async {
    try {
      final XFile? pickedFile = type == MediaType.image
          ? await _picker.pickImage(source: source)
          : await _picker.pickVideo(
              source: source,
              maxDuration: config.maxVideoDuration,
            );

      if (pickedFile == null) {
        throw MediaSelectionCancelledException();
      }

      File processedFile = File(pickedFile.path);

      // Process based on type
      if (type == MediaType.image) {
        processedFile = await _compressImage(
          processedFile,
          config.imageQuality,
        );
      }

      // Check final file size
      final int sizeInBytes = await processedFile.length();
      final double calculatedSizeInMB =
          sizeInBytes / (1024 * 1024); // <-- Add this calculation

      if (sizeInBytes > config.maxBytes) {
        throw MediaSizeExceededException(
          'File size (${calculatedSizeInMB.toStringAsFixed(2)}MB) exceeds limit of ${config.maxSizeMB}MB.',
        );
      }

      // Generate thumbnail if it's a video
      File? thumbnailFile;
      if (type == MediaType.video) {
        thumbnailFile = await _generateThumbnail(processedFile.path);
      }

      return SmartMedia(
        file: processedFile,
        type: type,
        sizeInMb: calculatedSizeInMB,
        thumbnail: thumbnailFile,
      );
    } on MediaSelectionCancelledException {
      rethrow; // Pass cancellation up to the UI safely
    } on MediaSizeExceededException {
      rethrow; // Pass size validation up
    } catch (e) {
      throw MediaProcessingException(
        'An error occurred while processing media: $e',
      );
    }
  }

  /// New entry point specifically for picking generic files (PDFs, Docs, etc.)
  Future<SmartMedia> pickFile({
    required MediaConfig config,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.single.path == null) {
        throw MediaSelectionCancelledException();
      }

      File processedFile = File(result.files.single.path!);

      // Check final file size to ensure it respects the MediaConfig
      final int sizeInBytes = await processedFile.length();
      final double calculatedSizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInBytes > config.maxBytes) {
        throw MediaSizeExceededException(
          'File size (${calculatedSizeInMB.toStringAsFixed(2)}MB) exceeds limit of ${config.maxSizeMB}MB.',
        );
      }

      return SmartMedia(
        file: processedFile,
        type: MediaType.file,
        sizeInMb: calculatedSizeInMB,
        fileName: result.files.single.name,
      );
    } on MediaSelectionCancelledException {
      rethrow;
    } on MediaSizeExceededException {
      rethrow;
    } catch (e) {
      throw MediaProcessingException(
        'An error occurred while processing the file: $e',
      );
    }
  }

  /// High-performance native image compression
  Future<File> _compressImage(File file, int quality) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw MediaProcessingException('Image compression failed.');
    }
    return File(result.path);
  }

  /// Generates a quick thumbnail for video previews
  Future<File?> _generateThumbnail(String videoPath) async {
    final dir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: dir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 400,
      quality: 75,
    );

    if (thumbnailPath == null) return null;
    return File(thumbnailPath);
  }
}
