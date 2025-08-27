class School {
  final String id;
  final String name;
  final String code;
  final String address;
  final String phone;
  final String password;

  School({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.phone,
    required this.password,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      phone: json['phone'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'phone': phone,
      'password': password,
    };
  }
}
