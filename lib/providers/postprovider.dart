import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leafy_mobile_app/models/postmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  String _baseUrl = 'http://127.0.0.1:8000/api/customer/posts';

  List<Post> get posts => _posts;

  Future<void> fetchAllPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse(_baseUrl);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _posts = data.map((json) => Post.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> createPost(String content, String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse(_baseUrl);

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['content'] = content
        ..headers['Authorization'] = 'Bearer $token';

      if (imagePath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Post newPost = Post.fromJson(json.decode(responseData));
        _posts.add(newPost);
        notifyListeners();
      } else {
        // Log error response for debugging
        final errorResponse = await response.stream.bytesToString();
        print('Failed to create post. Status code: ${response.statusCode}');
        print('Response body: $errorResponse');
        throw Exception('Failed to create post');
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  Future<void> likePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('$_baseUrl/like/$postId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      _posts.indexWhere((post) => post.id == postId);
    } else {
      throw Exception('Failed to like post');
    }
  }

  Future<void> commentOnPost(int postId, String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('$_baseUrl/$postId/comment');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic>? responseData = json.decode(response.body);
        try {
          final Comment newComment = Comment.fromJson(responseData);
          final postIndex = _posts.indexWhere((post) => post.id == postId);
          if (postIndex != -1) {
            _posts[postIndex].comments.add(newComment);
            notifyListeners();
          }
        } catch (e) {
          throw Exception('Failed to parse comment data: $e');
        }
      } else {
        throw Exception(
            'Failed to comment on post. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to add comment: $e');
      throw Exception('Failed to comment on post: $e');
    }
  }

  Future<void> searchPosts(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('$_baseUrl/$query');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _posts = data.map((json) => Post.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to search posts');
    }
  }

  Future<void> deletePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('$_baseUrl/$postId');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } else {
      throw Exception('Failed to delete post');
    }
  }
}
