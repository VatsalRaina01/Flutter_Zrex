import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/feed_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/stories_tray.dart';
import '../widgets/post_widget.dart';

class HomeFeed extends ConsumerStatefulWidget {
  const HomeFeed({super.key});

  @override
  ConsumerState<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends ConsumerState<HomeFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 1000 pixels is roughly 1.5 to 2 posts away from the bottom depending on screen size
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 1000) {
      ref.read(feedProvider.notifier).fetchMore();
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Shimmer for Stories
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(width: 60, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Shimmer for Posts
          ...List.generate(2, (index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(width: 120.0, height: 14.0, color: Colors.white),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 28, height: 28, color: Colors.white, margin: const EdgeInsets.only(right: 8)),
                          Container(width: 28, height: 28, color: Colors.white, margin: const EdgeInsets.only(right: 8)),
                          Container(width: 28, height: 28, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(width: double.infinity, height: 14.0, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 200, height: 14.0, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedStateAsync = ref.watch(feedProvider);

    return Scaffold(
      appBar: const TopBar(),
      body: feedStateAsync.when(
        data: (feedState) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: StoriesTray()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == feedState.posts.length) {
                      return feedState.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : const SizedBox.shrink();
                    }
                    return PostWidget(post: feedState.posts[index]);
                  },
                  childCount: feedState.posts.length + 1,
                ),
              ),
            ],
          );
        },
        loading: () => _buildShimmerLoading(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
