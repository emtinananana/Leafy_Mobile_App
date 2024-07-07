import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leafy_mobile_app/models/commentmodel.dart';
import 'package:leafy_mobile_app/models/postmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
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

  Future<List<PostModel>> fetchLikedPosts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customer/likedposts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['liked_posts'];
        _likedPostIds =
            data.map<int>((json) => PostModel.fromJson(json).id).toSet();
        notifyListeners();
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch liked posts');
      }
    } catch (e) {
      print('Error fetching liked posts: $e');
      // Handle error appropriately, e.g., show error message
      throw e; // Optionally rethrow to propagate the error
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

  Future<void> createPost(String content, String image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('http://127.0.0.1:8000/api/customer/posts');
    final response = await http.post(
      url,
      body: json.encode({'content': content, 'image': image}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

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
}
