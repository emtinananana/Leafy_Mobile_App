import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leafy_mobile_app/models/commentmodel.dart';
import 'package:leafy_mobile_app/models/postmodel.dart';
import 'package:leafy_mobile_app/providers/authprovider.dart';
import 'package:leafy_mobile_app/providers/postprovider.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _postImageController = TextEditingController();

  List<PostModel> _posts = []; // List to hold all posts

  @override
  void initState() {
    super.initState();
    // Fetch posts when screen initializes
    _fetchPosts();
    // Listen to changes in the search input
    _searchController.addListener(() {
      _filterPosts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _truncatePostContent(String content, bool showFullContent) {
    const maxLength = 100;

    if (showFullContent) {
      return content;
    }

    if (content.length <= maxLength) {
      return content;
    }

    return '${content.substring(0, maxLength)}...';
  }

  void toggleLike(PostModel post) {
    try {
      final postsProvider = Provider.of<PostProvider>(context, listen: false);
      postsProvider.toggleLikePost(post.id).then((_) async {
        setState(() {});
        await _fetchPosts();
      }).catchError((error) {
        print('Error toggling like: $error');
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _fetchPosts() async {
    try {
      List<PostModel> posts =
          await Provider.of<PostProvider>(context, listen: false).fetchPosts();

      setState(() {
        _posts = posts;
      });
    } catch (error) {
      if (error.toString().contains('404')) {
        setState(() {
          _posts = [];
        });
      } else {
        print('Error fetching posts: $error');
      }
    }
  }

  Future<void> _filterPosts(String query) async {
    try {
      List<PostModel> filteredPosts;
      if (query.isEmpty) {
        filteredPosts = await Provider.of<PostProvider>(context, listen: false)
            .fetchPosts();
      } else {
        filteredPosts = await Provider.of<PostProvider>(context, listen: false)
            .searchPosts(query);
      }
      setState(() {
        _posts = filteredPosts;
      });
    } catch (error) {
      if (error.toString().contains('404')) {
        setState(() {
          _posts = [];
        });
      } else {
        print('Error filtering posts: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Posts',
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color.fromARGB(221, 44, 163, 58),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchPosts();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Posts',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(221, 44, 163, 58)),
                  hintText: 'Search...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(221, 44, 163, 58),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear,
                        color: Color.fromARGB(221, 44, 163, 58)),
                    onPressed: () {
                      _searchController.clear();
                      _filterPosts('');
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: _posts.isEmpty
                  ? const Center(
                      child: Text(
                        'No posts available.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        PostModel post = _posts[index];
                        bool isUserPost = post.customer.id ==
                            Provider.of<AuthProvider>(context).user.id;
                        bool isLiked = Provider.of<PostProvider>(context)
                            .likedPostIds
                            .contains(post.id);
                        bool showFullContent = false;

                        return Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    if (post.image != null &&
                                        post.image.isNotEmpty)
                                      Image.network(
                                        post.image,
                                        fit: BoxFit.contain,
                                      ),
                                    const SizedBox(height: 8),
                                    PostWidget(content: post.content),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'By: ${post.customer.name}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${post.postDate}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isLiked
                                                    ? Colors.red
                                                    : Colors.grey,
                                                size: 30,
                                              ),
                                              onPressed: () {
                                                toggleLike(
                                                    post); // Toggle the like status
                                                final message = isLiked
                                                    ? 'Post unliked successfully!'
                                                    : 'Post liked successfully!';
                                                final snackBar = SnackBar(
                                                  content: Text(message),
                                                  backgroundColor: Colors.green,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              },
                                            ),
                                            Text('${post.likeCount} Likes'),
                                            const SizedBox(width: 3),
                                            IconButton(
                                              icon: const Icon(Icons.chat,
                                                  color: Color.fromARGB(
                                                      221, 44, 163, 58)),
                                              onPressed: () {
                                                _showCommentDialog(post);
                                              },
                                            ),
                                            isUserPost
                                                ? PopupMenuButton(
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      221,
                                                                      44,
                                                                      163,
                                                                      58)),
                                                        ),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      if (value == 'delete') {
                                                        _confirmDeletePost(
                                                            post);
                                                      }
                                                    },
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (post.comments.isNotEmpty) ...[
                                      const Divider(),
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Comments:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: post.comments.length,
                                        itemBuilder: (context, commentIndex) {
                                          CommentModel comment =
                                              post.comments[commentIndex];
                                          return ListTile(
                                            title: Text(comment.content),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                  'By: ${comment.customer.name}'),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(221, 44, 163, 58),
        onPressed: () {
          _showCreatePostDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
// void _likePost(PostModel post) async {
//   try {
//     await Provider.of<PostProvider>(context, listen: false).toggleLikePost(post.id);

//     // Update the local isLiked state
//     setState(() {
//     isLiked = !isLiked;
//     });

//     final message = isLiked
//         ? 'Post unliked successfully!'
//         : 'Post liked successfully!';
//     final snackBar = SnackBar(content: Text(message));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   } catch (error) {
//     print('Error liking/unliking post: $error');
//   }
// }

  void _showCommentDialog(PostModel post) {
    String errorMessage = ''; // Variable to store error message

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Comment',
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  color: const Color.fromARGB(221, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          errorMessage = '';
                        });
                      }
                    },
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Comment',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58)),
                  ),
                  onPressed: () async {
                    if (_commentController.text.isEmpty) {
                      setState(() {
                        errorMessage = 'Please enter a comment';
                      });
                    } else {
                      try {
                        await Provider.of<PostProvider>(context, listen: false)
                            .addComment(post.id, _commentController.text);

                        // Fetch updated posts list after adding comment
                        await _fetchPosts();

                        Navigator.of(context).pop(); // Close dialog
                        _commentController.clear(); // Clear comment text field
                      } catch (error) {
                        setState(() {
                          errorMessage = 'Error adding comment: $error';
                        });
                        print('Error adding comment: $error');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    XFile? _pickedImage; // Use XFile to store picked image
    String errorMessage = '';

    Future<void> _pickImage(
        ImageSource source, Function(void Function()) setState) async {
      final pickedImageFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 50,
      );

      setState(() {
        _pickedImage = pickedImageFile; // Assign XFile to _pickedImage
        if (_postContentController.text.isNotEmpty) {
          errorMessage = '';
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _postContentController,
                    maxLines: 5,
                    onChanged: (value) {
                      if (value.isNotEmpty && _pickedImage != null) {
                        setState(() {
                          errorMessage = ''; // Clear the error message
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter post content',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(221, 44, 163, 58)),
                        onPressed: () =>
                            _pickImage(ImageSource.camera, setState),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(221, 44, 163, 58)),
                        onPressed: () =>
                            _pickImage(ImageSource.gallery, setState),
                        icon: const Icon(Icons.image),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_pickedImage != null)
                    Image.file(
                      File(_pickedImage!.path), // Display picked image
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () async {
                    if (_postContentController.text.isEmpty &&
                        _pickedImage == null) {
                      setState(() {
                        errorMessage = 'Please enter content and pick an image';
                      });
                    } else if (_postContentController.text.isEmpty) {
                      setState(() {
                        errorMessage = 'Please enter content';
                      });
                    } else if (_pickedImage == null) {
                      setState(() {
                        errorMessage = 'Please pick an image';
                      });
                    } else {
                      try {
                        if (_pickedImage != null) {
                          String postImagePath = _pickedImage!.path;
                          await Provider.of<PostProvider>(context,
                                  listen: false)
                              .createPost(
                            _postContentController.text,
                            postImagePath,
                          );

                          await _fetchPosts();

                          Navigator.of(context).pop();
                          _postContentController.clear();
                          setState(() {
                            _pickedImage = null;
                          });
                        }
                      } catch (error) {
                        setState(() {
                          errorMessage = 'Error creating post: $error';
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeletePost(PostModel post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete',
              style: GoogleFonts.oswald(
                  fontSize: 24,
                  color: const Color.fromARGB(221, 0, 0, 0),
                  fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete',
                  style: TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
              onPressed: () async {
                try {
                  await Provider.of<PostProvider>(context, listen: false)
                      .deletePost(post.id);

                  // Update _posts after deletion
                  setState(() {
                    _posts.remove(post);
                  });

                  Navigator.of(context).pop(); // Close dialog
                } catch (error) {
                  print('Error deleting post: $error');
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class PostWidget extends StatefulWidget {
  final String content;

  const PostWidget({Key? key, required this.content}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool showFullContent = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showFullContent ? widget.content : _truncateString(widget.content),
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
          maxLines:
              showFullContent ? null : 2, // Limit to 2 lines when not expanded
          overflow: showFullContent
              ? TextOverflow.visible
              : TextOverflow.ellipsis, // Show ellipsis when not expanded
        ),
        if (!_isContentShort())
          TextButton(
            onPressed: () {
              setState(() {
                showFullContent = !showFullContent;
              });
            },
            child: Text(
              showFullContent ? 'Read Less' : 'Read More',
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  bool _isContentShort() {
    return widget.content.length <= 100;
  }

  String _truncateString(String content) {
    final words = content.split(' ');
    if (words.length <= 20) {
      return content;
    }
    return words.take(20).join(' ') + '...';
  }
}
