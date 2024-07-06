import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/providers/postprovider.dart';
import 'package:provider/provider.dart';

import 'package:leafy_mobile_app/models/postmodel.dart';

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Post Screen'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          List<Post> posts = provider.posts;

          if (posts.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              Post post = posts[index];
              return PostItem(post: post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddPostDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final Post post;

  PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            if (post.image.isNotEmpty)
              Image.network(
                post.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16.0),
            Text(
              'Posted on: ${post.postDate}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            Text(
              'Comments (${post.comments.length})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: post.comments
                  .map((comment) => CommentItem(comment: comment))
                  .toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddCommentDialog(postId: post.id),
                );
              },
              child: Text('Add Comment'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;

  CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.content,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 4.0),
          Text(
            'By: ${comment.customer.name}',
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            'Posted on: ${comment.commentDate}',
            style: TextStyle(color: Colors.grey),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class AddPostDialog extends StatelessWidget {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 10),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Add Post",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: "Enter your post content",
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _imageController,
            decoration: InputDecoration(
              hintText: "Enter image URL (optional)",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              String content = _contentController.text.trim();
              String imagePath = _imageController.text.trim();
              try {
                await Provider.of<PostProvider>(context, listen: false)
                    .createPost(content, imagePath);
                Navigator.of(context).pop();
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to add post. Please try again.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text("Add Post"),
          ),
        ],
      ),
    );
  }
}

class AddCommentDialog extends StatelessWidget {
  final int postId;
  final TextEditingController _commentController = TextEditingController();

  AddCommentDialog({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 10),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Add Comment",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Enter your comment",
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              String content = _commentController.text.trim();

              try {
                await Provider.of<PostProvider>(context, listen: false)
                    .commentOnPost(postId, content);
                Navigator.of(context).pop();
              } catch (e) {
                print('Failed to add comment: $e');
                // Handle error display or logging here
              }
            },
            child: Text("Add Comment"),
          ),
        ],
      ),
    );
  }
}
