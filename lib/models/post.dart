import 'user.dart';

class Post {
  final String id;
  final User user;
  final List<String> imageUrls;
  final String caption;
  final int likes;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isSaved;

  const Post({
    required this.id,
    required this.user,
    required this.imageUrls,
    required this.caption,
    required this.likes,
    required this.commentsCount,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
  });

  Post copyWith({
    bool? isLiked,
    bool? isSaved,
    int? likes,
  }) {
    return Post(
      id: id,
      user: user,
      imageUrls: imageUrls,
      caption: caption,
      likes: likes ?? this.likes,
      commentsCount: commentsCount,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
