import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_playerhq/pages/about_app_page.dart';
import 'package:mobile_playerhq/pages/game_page.dart';
import 'package:mobile_playerhq/pages/post/create_post.dart';
import 'package:mobile_playerhq/provider/post.dart';
import 'package:mobile_playerhq/provider/user.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _fetchPostsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    _fetchPostsFuture = postProvider.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    List<Widget> pages = [
      _buildPostsPage(postProvider),
      const GamePage(),
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Home",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey.shade900,
          elevation: 0,
          leading: Builder(
            builder: (BuildContext context) => IconButton(
              icon: const Icon(Icons.menu), // Menu icon
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: Colors.white, // Set the color of the leading icon here
            ),
          )),
      drawer: Drawer(
        child: Container(
          color: Colors.grey.shade100,
          child: Column(
            children: [
              userProvider.isLoading
                  ? const DrawerHeader(
                      child: Center(
                          child:
                              CircularProgressIndicator(color: Colors.black)))
                  : user == null
                      ? DrawerHeader(
                          child: Center(child: Text(userProvider.errorMessage)))
                      : GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: DrawerHeader(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(
                      icon: Icons.post_add,
                      label: "Create Post",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreatePostPage(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      label: "About App",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutAppPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games_outlined),
            label: 'Games',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildPostsPage(PostProvider postProvider) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return FutureBuilder(
      future: _fetchPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          log("Fetching posts...");
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          );
        } else if (postProvider.posts.isEmpty) {
          return const Center(
            child: Text(
              'No posts available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        final reversedPosts = List.from(postProvider.posts.reversed);

        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            // Trigger a refresh by calling the fetchPosts method again
            await postProvider.fetchPosts();
          },
          child: ListView.builder(
            itemCount: reversedPosts.length,
            itemBuilder: (context, index) {
              final post = reversedPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/postDetail', arguments: post);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  .format(DateTime.parse(post.createdAt)),
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
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(12),
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
            },
          ),
        );
      },
    );
  }
}
