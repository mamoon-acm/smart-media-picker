/// Thrown when the user opens the picker but closes it without selecting anything.
class MediaSelectionCancelledException implements Exception {
  final String message;
  MediaSelectionCancelledException([this.message = 'User cancelled media selection.']);
  
  @override
  String toString() => message;
}

/// Thrown when the selected file exceeds the maximum allowed size defined in config.
class MediaSizeExceededException implements Exception {
  final String message;
  MediaSizeExceededException([this.message = 'Selected media exceeds the maximum size limit.']);
  
  @override
  String toString() => message;
}

/// Thrown when compression fails or the platform throws an unexpected error.
class MediaProcessingException implements Exception {
  final String message;
  MediaProcessingException([this.message = 'Failed to process the media file.']);
  
  @override
  String toString() => message;
}