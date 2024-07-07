class CustomerModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String phone;
  final String address;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.phone,
    required this.address,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
