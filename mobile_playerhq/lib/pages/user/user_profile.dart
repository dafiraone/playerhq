import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_playerhq/pages/post/post_detail.dart';
import 'package:mobile_playerhq/pages/user/edit_profile.dart';
import 'package:mobile_playerhq/pages/user/game_list.dart';
import 'package:mobile_playerhq/provider/post.dart';
import 'package:mobile_playerhq/provider/user.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final user = userProvider.user;

    final reversedPosts = List.from(postProvider.posts.reversed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0, // No elevation for a flat design
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              // Navigate to Edit Profile Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage(user: user!), // Pass the current user
                ),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 50,
                            backgroundImage: user.imageBytes != null
                                ? MemoryImage(user.imageBytes!)
                                : const AssetImage(
                                        'assets/profile_placeholder.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 8),
                          // Username
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Bio (Optional)
                          if (user.bio != null && user.bio!.isNotEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  user.bio!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          // Account Created (formatted)
                          Text(
                            'Joined: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(user.createdAt))}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // View Game List Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to UserGameList Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserGameList(userId: user.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 24),
                      backgroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: const Text(
                      'View Game List',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Display Posts
                  if (postProvider.posts.isNotEmpty)
                    ListView.builder(
                      shrinkWrap:
                          true, // Prevent the ListView from expanding to full screen
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reversedPosts.length,
                      itemBuilder: (context, index) {
                        final post = reversedPosts[index];
                        // Only show posts from the current user
                        if (post.userId == user.userId) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/postDetail',
                                  arguments: post);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12.0,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (post.content != null)
                                          Text(
                                            post.content!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMMM dd, yyyy • h:mm a')
                                              .format(DateTime.parse(
                                                  post.createdAt)),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (post.imageBytes != null)
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.memory(
                                          post.imageBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
