import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/media_config.dart';
import '../domain/media_model.dart';
import '../domain/media_service.dart';

class SmartMediaField extends StatefulWidget {
  /// Callback triggered when the media is successfully picked and compressed
  final Function(SmartMedia) onMediaReady;

  /// Callback triggered when the user clears the selected media
  final VoidCallback? onClear;

  /// Configuration for file size and quality
  final MediaConfig config;

  /// Whether to pick an image or a video
  final MediaType mediaType;

  /// Custom text for the pick button
  final String buttonText;

  /// Box fit for the media
  final BoxFit boxFit;

  /// Height of the media container
  final double height;

  /// Width of the media container
  final double width;

  // --- Design Customization Properties ---

  /// Background color of the container
  final Color backgroundColor;

  /// Border color of the container
  final Color borderColor;

  /// Border radius of the container
  final double borderRadius;

  /// Icon displayed in the empty state
  final IconData emptyIcon;

  /// Color of the empty state icon
  final Color iconColor;

  /// Text style for the empty state text
  final TextStyle? textStyle;

  /// Color of the loading indicator
  final Color? loadingIndicatorColor;

  /// Icon used for the clear button
  final IconData clearIcon;

  /// Color of the clear button icon
  final Color clearIconColor;

  const SmartMediaField({
    super.key,
    required this.onMediaReady,
    this.onClear,
    this.config = const MediaConfig(),
    this.mediaType = MediaType.image,
    this.buttonText = 'Select Media',
    this.boxFit = BoxFit.cover,
    this.height = 150,
    this.width = double.infinity,
    // Default design values
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.borderColor = const Color(0xFFBDBDBD),
    this.borderRadius = 12.0,
    this.emptyIcon = Icons.cloud_upload_outlined,
    this.iconColor = Colors.grey,
    this.textStyle,
    this.loadingIndicatorColor,
    this.clearIcon = Icons.close,
    this.clearIconColor = Colors.white,
  });

  @override
  State<SmartMediaField> createState() => _SmartMediaFieldState();
}

class _SmartMediaFieldState extends State<SmartMediaField> {
  final MediaService _mediaService = MediaService();

  SmartMedia? _selectedMedia;
  bool _isLoading = false;
  // String? _errorMessage;

  Future<void> _handleMediaPick() async {
    setState(() {
      _isLoading = true;
      // _errorMessage = null;
    });

    try {
      final media = await _mediaService.pickMedia(
        type: widget.mediaType,
        source: ImageSource.gallery,
        config: widget.config,
      );

      setState(() {
        _selectedMedia = media;
        _isLoading = false;
      });

      widget.onMediaReady(media);
    } catch (e) {
      setState(() {
        _isLoading = false;
        // _errorMessage = e.toString();
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _selectedMedia = null;
      // _errorMessage = null;
    });
    // Trigger the optional clear callback so the parent form can update its state
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (_isLoading || _selectedMedia != null)
              ? null
              : _handleMediaPick,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(color: widget.borderColor, width: 1),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: _buildContent(),
          ),
        ),

        // Optional Error Handling

        // if (_errorMessage != null) ...[
        //   const SizedBox(height: 8),
        //   Text(
        //     _errorMessage!,
        //     style: const TextStyle(color: Colors.red, fontSize: 12),
        //   ),
        // ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.loadingIndicatorColor),
            const SizedBox(height: 12),
            Text(
              'Processing...',
              style: widget.textStyle ?? TextStyle(color: widget.iconColor),
            ),
          ],
        ),
      );
    }

    if (_selectedMedia != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Media Display
          ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.borderRadius - 1,
            ), // -1 to fit inside border smoothly
            child: Image.file(
              _selectedMedia!.type == MediaType.image
                  ? _selectedMedia!.file
                  : _selectedMedia!.thumbnail!,
              fit: widget.boxFit,
            ),
          ),

          // Video Play Icon Overlay
          if (_selectedMedia!.type == MediaType.video)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 50,
              ),
            ),

          // File Size Indicator (Bottom Right)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_selectedMedia!.sizeInMB.toStringAsFixed(2)} MB',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),

          // Clear Button (Top Right)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _clearMedia,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.clearIcon,
                  color: widget.clearIconColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default Empty State
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.emptyIcon, size: 40, color: widget.iconColor),
          const SizedBox(height: 8),
          Text(
            widget.buttonText,
            style:
                widget.textStyle ??
                TextStyle(color: widget.iconColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
