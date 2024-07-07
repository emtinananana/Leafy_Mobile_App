import 'package:leafy_mobile_app/models/customermodel.dart';

class CommentModel {
  final int id;
  final int customerId;
  final int postId;
  final String content;
  final String commentDate;
  final CustomerModel customer;

  CommentModel({
    required this.id,
    required this.customerId,
    required this.postId,
    required this.content,
    required this.commentDate,
    required this.customer,
  });

  factory CommentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to parse JSON');
    }

    return CommentModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      content: json['content'] ?? '',
      commentDate: json['comment_date'] ?? '',
      customer: CustomerModel.fromJson(json['customer'] ?? {}),
    );
  }
}
