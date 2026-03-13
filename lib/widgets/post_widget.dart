import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../providers/feed_provider.dart';
import 'pinch_to_zoom_image.dart';

class PostWidget extends ConsumerStatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  ConsumerState<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends ConsumerState<PostWidget> {
  int _currentImageIndex = 0;

  void _showUnimplementedSnackbar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action not implemented yet'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: CachedNetworkImageProvider(widget.post.user.profileImageUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.post.user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (widget.post.user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 14),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showUnimplementedSnackbar(context, 'Options'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        
        // Carousel of Images
        Stack(
          alignment: Alignment.topRight,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: PageView.builder(
                itemCount: widget.post.imageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return PinchToZoomImage(imageUrl: widget.post.imageUrls[index]);
                },
              ),
            ),
            if (widget.post.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${widget.post.imageUrls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),

        // Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.post.isLiked ? Colors.red : Colors.black,
                  size: 28,
                ),
                onPressed: () {
                  ref.read(feedProvider.notifier).toggleLike(widget.post.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 26),
                onPressed: () => _showUnimplementedSnackbar(context, 'Comments'),
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 26),
                onPressed: () => _showUnimplementedSnackbar(context, 'Share'),
              ),
              Expanded(
                child: widget.post.imageUrls.length > 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.post.imageUrls.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            width: _currentImageIndex == index ? 6.0 : 4.0,
                            height: _currentImageIndex == index ? 6.0 : 4.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.blue
                                  : Colors.black26,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              IconButton(
                icon: Icon(
                  widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () {
                  ref.read(feedProvider.notifier).toggleSave(widget.post.id);
                },
              ),
            ],
          ),
        ),

        // Likes, Caption, Comments
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.post.likes} likes',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                  children: [
                    TextSpan(
                      text: '${widget.post.user.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (widget.post.commentsCount > 0)
                GestureDetector(
                  onTap: () => _showUnimplementedSnackbar(context, 'View Comments'),
                  child: Text(
                    'View all ${widget.post.commentsCount} comments',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                timeago.format(widget.post.createdAt),
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
