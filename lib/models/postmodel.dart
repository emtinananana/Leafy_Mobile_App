class Post {
  final int id;
  final int customerId;
  final String content;
  final String postDate;
  final String image;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> comments;
  final Customer customer;

  Post({
    required this.id,
    required this.customerId,
    required this.content,
    required this.postDate,
    required this.image,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    required this.customer,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      customerId: json['customer_id'],
      content: json['content'],
      postDate: json['post_date'],
      image: json['image'],
      likeCount: json['like_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      customer: Customer.fromJson(json['customer']),
    );
  }
}

class Comment {
  final int id;
  final int customerId;
  final int postId;
  final String content;
  final String commentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Customer customer;

  Comment({
    required this.id,
    required this.customerId,
    required this.postId,
    required this.content,
    required this.commentDate,
    this.createdAt,
    this.updatedAt,
    required this.customer,
  });

  factory Comment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to load comment');
    }

    return Comment(
      id: json['id'] ?? 0, // Provide a default value or handle appropriately
      customerId: json['customer_id'] ??
          0, // Provide a default value or handle appropriately
      postId: json['post_id'] ??
          0, // Provide a default value or handle appropriately
      content: json['content'] ??
          '', // Provide a default value or handle appropriately
      commentDate: json['comment_date'] ??
          '', // Provide a default value or handle appropriately
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      customer: Customer.fromJson(
          json['customer'] ?? {}), // Pass an empty map as default
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      phone: json['phone'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
