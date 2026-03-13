import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

class FeedState {
  final List<Post> posts;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;

  const FeedState({
    required this.posts,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 0,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FeedNotifier extends AsyncNotifier<FeedState> {
  static const int _limit = 10;

  @override
  Future<FeedState> build() async {
    final repository = ref.watch(postRepositoryProvider);
    final posts = await repository.fetchPosts(page: 0, limit: _limit);
    return FeedState(
      posts: posts,
      currentPage: 0,
      hasReachedMax: posts.length < _limit,
    );
  }

  Future<void> fetchMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || currentState.hasReachedMax) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(postRepositoryProvider);
      final nextPage = currentState.currentPage + 1;
      final newPosts = await repository.fetchPosts(page: nextPage, limit: _limit);
      
      state = AsyncValue.data(currentState.copyWith(
        posts: [...currentState.posts, ...newPosts],
        currentPage: nextPage,
        isLoadingMore: false,
        hasReachedMax: newPosts.length < _limit,
      ));
    } catch (e) {
      // Don't lose existing data on error
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      // Could potentially log or signal error side-effect here
    }
  }

  void toggleLike(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedPosts = currentState.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
      return post;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(posts: updatedPosts));
  }
  
  void toggleSave(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedPosts = currentState.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(isSaved: !post.isSaved);
      }
      return post;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(posts: updatedPosts));
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, FeedState>(() {
  return FeedNotifier();
});
