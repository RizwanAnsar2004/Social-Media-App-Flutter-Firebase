import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<http.Response> signUp(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return response;
  }

  Future<http.Response> login(Map<String, dynamic> loginData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    return response;
  }

  Future<http.Response> addPost(Map<String, dynamic> postData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(postData),
    );
    return response;
  }

  Future<http.Response> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/post/$postId'),
    );
    return response;
  }

  Future<http.Response> addComment(String postId, ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/post/$postId/comment'),
      headers: {'Content-Type': 'application/json'},
      // body: jsonEncode(commentData),
    );
    return response;
  }

  Future<http.Response> getComments(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/post/$postId/comments'),
    );
    return response;
  }

  Future<http.Response> deleteComment(String commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
    );
    return response;
  }

  Future<http.Response> getUserPosts(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/posts'),
    );
    return response;
  }

  Future<http.Response> getUserName(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
    );
    return response;
  }

  Future<http.Response> followFriend(Map<String, dynamic> followData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(followData),
    );
    return response;
  }

  Future<http.Response> unfollowFriend(Map<String, dynamic> unfollowData) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/friends'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unfollowData),
    );
    return response;
  }

  Future<http.Response> getFriendsList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends'),
    );
    return response;
  }

  Future<http.Response> getFriends(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends/$userId'),
    );
    return response;
  }

  Future<http.Response> getPosts(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$userId'),
    );
    return response;
  }
}
