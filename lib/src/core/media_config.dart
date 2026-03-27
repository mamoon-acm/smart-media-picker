/// Settings like max duration, compression quality, and other media-related configurations.
class MediaConfig {
  final int maxDuration; // In seconds
  final int compressionQuality; // 0 to 100
  final int maxFileSize; // In bytes

  const MediaConfig({
    this.maxDuration = 30,
    this.compressionQuality = 80,
    this.maxFileSize = 10 * 1024 * 1024, // 10 MB
  });
}
