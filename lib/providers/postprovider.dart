import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leafy_mobile_app/models/commentmodel.dart';
import 'package:leafy_mobile_app/models/postmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  List<PostModel> _likedPosts = []; // Initialize as an empty list
  Set<int> _likedPostIds = {}; // Set to store liked post IDs

  List<PostModel> get posts => _posts;
  Set<int> get likedPostIds => _likedPostIds;

  PostProvider() {
    fetchLikedPosts(); // Initialize liked posts from SharedPreferences
  }

  Future<List<PostModel>> fetchPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('http://127.0.0.1:8000/api/customer/posts');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      _posts = responseData.map((data) => PostModel.fromJson(data)).toList();
      notifyListeners();
      return _posts;
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  Future<void> fetchLikedPosts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/customer/likedposts"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Check if liked_posts is null
        if (responseBody['liked_posts'] != null) {
          _likedPosts = (responseBody['liked_posts'] as List)
              .map((post) => PostModel.fromJson(post))
              .toList();
          // Extract post IDs and update _likedPostIds
          _likedPostIds = _likedPosts.map((post) => post.id).toSet();
        } else {
          _likedPosts = []; // Set to an empty list if liked_posts is null
          _likedPostIds = {};
        }

        notifyListeners();
      } else {
        debugPrint("Error fetching liked posts: ${response.body}");
        throw Exception("Failed to fetch liked posts");
      }
    } catch (e) {
      debugPrint("Error fetching liked posts: $e");
      throw Exception("Failed to fetch liked posts");
    }
  }

  Future<void> toggleLikePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final likeUrl =
        Uri.parse('http://127.0.0.1:8000/api/customer/posts/like/$postId');
    final unlikeUrl =
        Uri.parse('http://127.0.0.1:8000/api/customer/posts/unlike/$postId');

    try {
      // Determine the URL based on whether the post is liked or not
      Uri url = isLiked(postId) ? unlikeUrl : likeUrl;

      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Update likedPostIds based on the toggle
        if (isLiked(postId)) {
          _likedPostIds.remove(postId);
        } else {
          _likedPostIds.add(postId);
        }
        // Save updated likedPostIds to SharedPreferences
        await _saveLikedPostIds();
        // Notify listeners or return something if needed
        notifyListeners();
      } else {
        throw Exception('Failed to toggle like status');
      }
    } catch (error) {
      print('Error toggling like: $error');
      throw error;
    }
  }

  bool isLiked(int postId) {
    return _likedPostIds.contains(postId);
  }

  Future<void> _saveLikedPostIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'liked_post_ids', _likedPostIds.map((id) => id.toString()).toList());
  }

  Future<void> addComment(int postId, String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url =
        Uri.parse('http://127.0.0.1:8000/api/customer/posts/$postId/comment');

    try {
      final response = await http.post(
        url,
        body: json.encode({'content': content}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response body to check if it's JSON
        final responseData = json.decode(response.body);
        if (responseData != null && responseData is Map<String, dynamic>) {
          // Handle the response as needed, e.g., update UI or fetch updated data
          await fetchPosts(); // Example refresh posts after adding a comment
        } else {
          throw Exception(
              'Invalid JSON response'); // Example of error handling for unexpected API response format
        }
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding comment: $error');
      throw error; // Propagate the error up if needed
    }
  }

  Future<void> createPost(String content, String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    // Create a multipart request
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/customer/posts'));

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add fields (content)
    request.fields['content'] = content;

    // Add image file
    var imageFile = await http.MultipartFile.fromPath('image', imagePath);
    request.files.add(imageFile);

    // Send request
    var response = await request.send();

    // Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      await fetchPosts();
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<List<PostModel>> searchPosts(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('http://127.0.0.1:8000/api/customer/posts/$query');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      List<PostModel> searchResults =
          responseData.map((data) => PostModel.fromJson(data)).toList();
      return searchResults;
    } else {
      throw Exception('Failed to search posts');
    }
  }

  Future<void> deletePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('http://127.0.0.1:8000/api/customer/post/$postId');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } else {
      throw Exception('Failed to delete post');
    }
  }

  Future<void> clearLikedPosts() async {
    _likedPosts = [];
    _likedPostIds = {};
    notifyListeners();
  }
}
