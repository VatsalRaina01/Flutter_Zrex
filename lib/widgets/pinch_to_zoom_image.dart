import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PinchToZoomImage extends StatefulWidget {
  final String imageUrl;

  const PinchToZoomImage({super.key, required this.imageUrl});

  @override
  State<PinchToZoomImage> createState() => _PinchToZoomImageState();
}

class _PinchToZoomImageState extends State<PinchToZoomImage> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  bool _isZooming = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _showOverlay(BuildContext context, ScaleStartDetails details) {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              top: offset.dy,
              left: offset.dx,
              width: renderBox.size.width,
              height: renderBox.size.height,
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: false, // Only allow zooming
                clipBehavior: Clip.none,
                minScale: 1.0,
                maxScale: 4.0,
                onInteractionEnd: (details) {
                  _resetAnimation();
                },
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isZooming = false;
    });
  }

  void _resetAnimation() {
    _transformationController.value = Matrix4.identity();
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onScaleStart: (details) {
            setState(() {
              _isZooming = true;
            });
            _showOverlay(context, details);
          },
          onScaleUpdate: (details) {
            if (_isZooming && _overlayEntry != null) {
              final double scale = details.scale.clamp(1.0, 4.0);
              
              // Calculate correct focal point shift
              final renderBox = context.findRenderObject() as RenderBox;
              final offset = renderBox.localToGlobal(Offset.zero);
              
              final focalPoint = details.localFocalPoint;
              
              // To scale from the focal point, we translate to the origin, scale, and translate back
              final Matrix4 newMatrix = Matrix4.identity()
                ..translate(focalPoint.dx, focalPoint.dy)
                ..scale(scale, scale, 1.0)
                ..translate(-focalPoint.dx, -focalPoint.dy);
                
              _transformationController.value = newMatrix;
              _overlayEntry?.markNeedsBuild();
            }
          },
          onScaleEnd: (details) {
             _resetAnimation();
          },
          child: Opacity(
            opacity: _isZooming ? 0.0 : 1.0,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }
    );
  }
}
