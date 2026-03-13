import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoriesTray extends StatelessWidget {
  const StoriesTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 15,
        itemBuilder: (context, index) {
          final isUser = index == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isUser
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF833AB4),
                                  Color(0xFFFD1D1D),
                                  Color(0xFFF56040),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isUser ? 0 : 2.5),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isUser ? 0 : 2.0),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                isUser 
                                  ? 'https://picsum.photos/seed/my_user/150/150' 
                                  : 'https://picsum.photos/seed/story_$index/150/150',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isUser)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isUser ? 'Your Story' : 'user_$index',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
