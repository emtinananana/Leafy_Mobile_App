class ProductModel {
  final int id;
  final String name;
  final String productType;
  final String description;
  final double price;
  final int likeCount;
  final int quantity;
  final String createdAt;
  final String updatedAt;
  final String firstImage;
  final List<ProductImage> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.productType,
    required this.description,
    required this.price,
    required this.likeCount,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.firstImage,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      productType: json['product_type'],
      description: json['description'],
      price: double.parse(json['price']),
      likeCount: json['like_count'],
      quantity: json['quantity'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      firstImage: json['first_image']
          .replaceFirst('127.0.0.1', '192.168.0.108'), // Replace IP
      images: (json['images'] as List)
          .map((i) => ProductImage.fromJson(i))
          .toList(),
    );
  }
}

class ProductImage {
  final int id;
  final int productId;
  final String image;
  final String createdAt;
  final String updatedAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      productId: json['product_id'],
      image: json['image']
          .replaceFirst('127.0.0.1', '192.168.0.114'), // Replace IP
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
