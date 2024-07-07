import 'package:leafy_mobile_app/models/commentmodel.dart';
import 'package:leafy_mobile_app/models/customermodel.dart';

class PostModel {
  final int id;
  final int customerId;
  final String content;
  final String postDate;
  final String image;
  final int likeCount;
  final List<CommentModel> comments;
  final CustomerModel customer;

  PostModel({
    required this.id,
    required this.customerId,
    required this.content,
    required this.postDate,
    required this.image,
    required this.likeCount,
    required this.comments,
    required this.customer,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse comments list
    List<CommentModel> comments = [];
    if (json['comments'] != null) {
      comments = List<CommentModel>.from(
        json['comments'].map((comment) => CommentModel.fromJson(comment)),
      );
    }

    return PostModel(
      id: json['id'],
      customerId: json['customer_id'],
      content: json['content'],
      postDate: json['post_date'],
      image: json['image'],
      likeCount: json['like_count'],
      comments: comments,
      customer: CustomerModel.fromJson(json['customer']),
    );
  }
}
