class MediaConfig {
  /// Maximum allowed size in Megabytes (MB). Defaults to 10MB.
  final double maxSizeMB;
  
  /// Image compression quality (0 to 100). Defaults to 70 for optimal size/quality ratio.
  final int imageQuality;
  
  /// Maximum duration for videos. Defaults to 60 seconds.
  final Duration maxVideoDuration;

  const MediaConfig({
    this.maxSizeMB = 10.0,
    this.imageQuality = 70,
    this.maxVideoDuration = const Duration(seconds: 60),
  });

  /// Helper to get max bytes for validation
  int get maxBytes => (maxSizeMB * 1024 * 1024).toInt();
}