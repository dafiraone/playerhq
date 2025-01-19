import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/models/post.dart';
import 'package:mobile_playerhq/models/comment.dart';
import 'package:mobile_playerhq/pages/post/edit_post.dart';
import 'package:mobile_playerhq/provider/post.dart';
import 'package:mobile_playerhq/provider/user.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;
  bool _isLoadingComments = true;
  String errorMessage = '';
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoadingComments = true;
      errorMessage = ''; // Clear previous error messages
    });

    try {
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_URL']}/api/posts/${widget.post.postId}/comments'), // Correct endpoint for fetching comments
      );

      if (response.statusCode == 200) {
        final List<dynamic> commentList = json.decode(response.body);

        final filteredComments = commentList
            .where(
                (commentJson) => commentJson['post_id'] == widget.post.postId)
            .map((commentJson) => Comment.fromJson(commentJson))
            .toList();

        setState(() {
          comments = filteredComments;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load comments';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching comments: $error';
      });
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _postComment() async {
    setState(() {
      _isPostingComment = true;
    });

    final String content = _commentController.text.trim();

    // Access user from the provider
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user == null) {
      // If the user is null, handle accordingly (you can show a message or navigate the user to login)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please log in.')),
      );
      setState(() {
        _isPostingComment = false;
      });
      return;
    }

    final int userId = user.userId; // Access userId

    if (content.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(
              '${dotenv.env['API_URL']}/api/posts/${widget.post.postId}/comments'), // Adjust API endpoint as necessary
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId, // Add userId here
            'content': content,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Comment posted successfully")),
          );
          _commentController.clear(); // Clear text after posting
          _fetchComments(); // Refresh comments
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
    }

    setState(() {
      _isPostingComment = false;
    });
  }

  Future<void> _deleteComment(int postId, int commentId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${dotenv.env['API_URL']}/api/posts/$postId/comments/$commentId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment deleted successfully")),
        );
        _fetchComments(); // Refresh comments
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
    }
  }

  Future<void> _deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/api/posts/$postId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully")),
        );
        await Provider.of<PostProvider>(context, listen: false).fetchPosts();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete Post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return Center(
          child: CircularProgressIndicator(
              color: Colors.black)); // Or handle the null user case
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0, // No elevation for a flat design
        actions: [
          if (widget.post.userId == user.userId)
            Row(
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostPage(post: widget.post),
                      ),
                    );
                  },
                ),
                // Delete button
                IconButton(
                  onPressed: () async {
                    _deletePost(widget.post.postId);
                    await Provider.of<PostProvider>(context, listen: false)
                        .fetchPosts();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.post.content != null
                        ? Text(
                            widget.post.content!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          )
                        : const Text(""),
                    const SizedBox(height: 12),
                    if (widget.post.imageBytes != null)
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // 90% of screen width
                          height: MediaQuery.of(context).size.height *
                              0.3, // 30% of screen height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.memory(
                            widget.post.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Posted: ${DateFormat('MMMM dd, yyyy • h:mm a').format(DateTime.parse(widget.post.createdAt))}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // Comments Section
                    _isLoadingComments
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.black))
                        : errorMessage.isNotEmpty
                            ? Center(child: Text(errorMessage))
                            : comments.isEmpty
                                ? const Center(child: Text("No comments yet"))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = comments[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  comment.content,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              if (comment.userId == user.userId)
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    _deleteComment(user.userId,
                                                        comment.commentId);
                                                  },
                                                )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ],
                ),
              ),
            ),
          ),

          // Spacer to push the comment section to the bottom
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add Comment',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: _isPostingComment
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Icon(Icons.send),
                  onPressed: _isPostingComment ? null : _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
