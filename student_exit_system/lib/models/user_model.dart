class User {
  final String id;
  final String name;
  final String phoneNumber;
  final List<dynamic> children;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.children,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      children: List<String>.from(json['children']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'children': children,
    };
  }
}
