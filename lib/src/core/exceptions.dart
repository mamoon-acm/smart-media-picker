/// Custom exceptions for the Smart Media Picker.
class MediaSizeExceededException implements Exception {
  final String message;
  MediaSizeExceededException([this.message = 'Media size exceeded the maximum limit.']);

  @override
  String toString() => 'MediaSizeExceededException: $message';
}
