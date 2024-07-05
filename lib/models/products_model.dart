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
  final List<Tag> tags;
  final List<PlantInstruction>?
      plantInstructions; // Optional field for plant instructions

  ProductModel({
    required this.id,
    required this.name,
    required this.productType,
    required this.description,
    required this.price,
    required this.likeCount,
    required this.quantity,
    this.createdAt = '',
    this.updatedAt = '',
    required this.firstImage,
    required this.images,
    required this.tags,
    this.plantInstructions, // Optional parameter
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        productType: json['product_type'] ?? '',
        description: json['description'] ?? '',
        price: double.tryParse(json['price'].toString()) ?? 0.0,
        likeCount: json['like_count'] ?? 0,
        quantity: json['quantity'] ?? 0,
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        firstImage: json['first_image'] ?? '',
        images: (json['images'] as List? ?? [])
            .map((i) => ProductImage.fromJson(i))
            .toList(),
        tags:
            (json['tags'] as List? ?? []).map((t) => Tag.fromJson(t)).toList(),
        plantInstructions: json['product_type'] == 'Plant'
            ? (json['plant_instruction'] as List? ?? [])
                .map((pi) => PlantInstruction.fromJson(pi))
                .toList()
            : null, // Conditional parsing based on product type
      );
    } catch (e) {
      print('Error parsing JSON for ProductModel: $e');
      throw Exception('Failed to parse product data');
    }
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
    try {
      return ProductImage(
        id: json['id'] ?? 0,
        productId: json['product_id'] ?? 0,
        image: json['image'] ?? '',
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );
    } catch (e) {
      print('Error parsing JSON for ProductImage: $e');
      throw Exception('Failed to parse product image data');
    }
  }
}

class Tag {
  final int id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    try {
      return Tag(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
    } catch (e) {
      print('Error parsing JSON for Tag: $e');
      throw Exception('Failed to parse tag data');
    }
  }
}

class PlantInstruction {
  final int id;
  final int productId;
  final String instruction;
  final String createdAt;
  final String updatedAt;

  PlantInstruction({
    required this.id,
    required this.productId,
    required this.instruction,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantInstruction.fromJson(Map<String, dynamic> json) {
    try {
      return PlantInstruction(
        id: json['id'] ?? 0,
        productId: json['product_id'] ?? 0,
        instruction: json['instruction'] ?? '',
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );
    } catch (e) {
      print('Error parsing JSON for PlantInstruction: $e');
      throw Exception('Failed to parse plant instruction data');
    }
  }
}
