import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../core/exceptions.dart';
import '../core/media_config.dart';
import 'media_model.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  /// Main entry point to pick and process media
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
      if (sizeInBytes > config.maxBytes) {
        throw MediaSizeExceededException(
          'File size (${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)}MB) exceeds limit of ${config.maxSizeMB}MB.',
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
        sizeInBytes: sizeInBytes,
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
      maxHeight: 400, // Keep memory footprint low
      quality: 75,
    );

    if (thumbnailPath == null) return null;
    return File(thumbnailPath);
  }
}
