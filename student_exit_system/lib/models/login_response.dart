import 'user_model.dart'; // أضف هذا
import 'student_model.dart';

class LoginResponse {
  final String message;
  final User user;
  final List<Student> children;

  LoginResponse({
    required this.message,
    required this.user,
    required this.children,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
      children: (json['user']['children'] as List<dynamic>)
          .map((childJson) => Student.fromJson(childJson))
          .toList(),
    );
  }
}
