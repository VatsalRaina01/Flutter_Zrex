import '../models/post.dart';
import '../models/user.dart';

class PostRepository {
  Future<List<Post>> fetchPosts({required int page, required int limit}) async {
    // Simulate latency
    await Future.delayed(const Duration(milliseconds: 2200));
    
    // Generate mock data using a seed to get consistent images
    return List.generate(limit, (index) {
      final globalIndex = page * limit + index;
      final id = globalIndex.toString();
      
      // Some realistic user data
      final isVerified = globalIndex % 4 == 0;
      final numImages = (globalIndex % 3) + 1; // 1 to 3 images

      return Post(
        id: id,
        user: User(
          id: 'u_$id',
          username: 'creative_user_$id',
          profileImageUrl: 'https://picsum.photos/seed/user_$globalIndex/150/150',
          isVerified: isVerified,
        ),
        imageUrls: List.generate(
          numImages,
          (imgIndex) => 'https://picsum.photos/seed/post_${globalIndex}_$imgIndex/600/750', // Instagram portrait aspect ratio
        ),
        caption: 'This is a beautiful shot from my recent adventures! 📸✨ #photography #nature #vibes $globalIndex',
        likes: 120 + (globalIndex * 17) % 1000,
        commentsCount: 10 + (globalIndex * 7) % 100,
        createdAt: DateTime.now().subtract(Duration(hours: globalIndex * 3 + 1)),
      );
    });
  }
}
