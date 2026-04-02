import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/media_config.dart';
import '../domain/media_model.dart';
import '../domain/media_service.dart';

class SmartMediaField extends StatefulWidget {
  final Function(SmartMedia) onMediaReady;
  final VoidCallback? onClear;
  final MediaConfig config;
  final MediaType mediaType;
  final String buttonText;
  final BoxFit boxFit;
  final double height;
  final double width;

  final bool allowFiles;
  final List<String>? allowedExtensions;

  // --- Design Customization Properties ---
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final IconData emptyIcon;
  final Color iconColor;
  final TextStyle? textStyle;
  final Color? loadingIndicatorColor;
  final IconData clearIcon;
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
    this.allowFiles = false,
    this.allowedExtensions = const [
      "pdf",
      "doc",
      "docx",
      "xls",
      "xlsx",
      "ppt",
      "pptx",
      "txt",
      "csv",
      "rtf",
    ],
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

  Future<void> _handleMediaPick({required ImageSource source}) async {
    setState(() => _isLoading = true);

    try {
      final media = await _mediaService.pickMedia(
        type: widget.mediaType,
        source: source,
        config: widget.config,
      );

      setState(() {
        _selectedMedia = media;
        _isLoading = false;
      });

      widget.onMediaReady(media);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFilePick() async {
    setState(() => _isLoading = true);

    try {
      final media = await _mediaService.pickFile(
        config: widget.config,
        allowedExtensions: widget.allowedExtensions,
      );

      setState(() {
        _selectedMedia = media;
        _isLoading = false;
      });

      widget.onMediaReady(media);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _clearMedia() {
    setState(() => _selectedMedia = null);
    if (widget.onClear != null) widget.onClear!();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (_isLoading || _selectedMedia != null)
              ? null
              : _showSourceBottomSheet,
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
          if (_selectedMedia!.type == MediaType.file)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 48,
                    color: widget.iconColor,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _selectedMedia!.fileName ?? 'Document Selected',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius - 1),
              child: Image.file(
                _selectedMedia!.type == MediaType.image
                    ? _selectedMedia!.file
                    : _selectedMedia!.thumbnail!,
                fit: widget.boxFit,
              ),
            ),

          if (_selectedMedia!.type == MediaType.video)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 50,
              ),
            ),

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
                '${_selectedMedia!.sizeInMb.toStringAsFixed(2)} MB',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),

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

  void _showSourceBottomSheet() {
    // 1. Determine if Camera/Gallery should be visible
    final bool showCameraAndGallery = widget.mediaType != MediaType.file;

    // 2. Determine if the File selection should be visible
    final bool showFileOption =
        widget.mediaType == MediaType.file || widget.allowFiles;

    showModalBottomSheet(
      context: context,
      backgroundColor: widget.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag indicator
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Only show Camera/Gallery if the mediaType is NOT a generic file
                if (showCameraAndGallery) ...[
                  // Camera Option
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        widget.mediaType == MediaType.video
                            ? Icons.videocam
                            : Icons.camera_alt,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      widget.mediaType == MediaType.video
                          ? 'Record a Video'
                          : 'Take a Photo',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _handleMediaPick(source: ImageSource.camera);
                    },
                  ),

                  // Gallery Option
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade50,
                      child: Icon(
                        widget.mediaType == MediaType.video
                            ? Icons.video_library
                            : Icons.photo_library,
                        color: Colors.purple,
                      ),
                    ),
                    title: Text(
                      widget.mediaType == MediaType.video
                          ? 'Choose Video from Gallery'
                          : 'Choose Photo from Gallery',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _handleMediaPick(source: ImageSource.gallery);
                    },
                  ),
                ],

                // Show File Option if specifically requested OR allowFiles is enabled
                if (showFileOption)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(
                        Icons.insert_drive_file,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text('Select Document (PDF, etc.)'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleFilePick();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
