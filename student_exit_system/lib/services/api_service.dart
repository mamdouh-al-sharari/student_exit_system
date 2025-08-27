import 'dart:convert';
import 'package:flutter/foundation.dart'; // أضف هذا
import 'package:http/http.dart' as http;
import '../models/student_model.dart';
import '../models/request_model.dart';


class ApiService {
  static String get baseUrl {
    // إذا كان على المتصفح
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    // إذا كان على Android
    else {
      return 'http://10.0.2.2:5000/api';
    }
  }

  // دالة تسجيل الدخول
  static Future<Map<String, dynamic>> login(
    String phoneNumber,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': phoneNumber,
        'password': password
        }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل تسجيل الدخول: ${response.statusCode}');
    }
  }

  // دالة تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> register(
    String name,
    String phoneNumber,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل في التسجيل: ${response.statusCode}');
    }
  }

  // دالة استرجاع الأبناء المرتبطين بولي الأمر
static Future<List<Student>> getChildren(String parentPhone) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/parents/phone/$parentPhone/children'),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Student.fromJson(item)).toList();
    } else {
      // معالجة الخطأ بشكل صحيح
      final dynamic errorData = json.decode(response.body);
      if (errorData is Map<String, dynamic>) {
        throw Exception(errorData['message'] ?? 'فشل في تحميل البيانات');
      } else {
        throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
      }
    }
  } catch (error) {
    print('Error in getChildren: $error');
    rethrow;
  }
}

  // دالة إنشاء طلب خروج
  static Future<void> createExitRequest({
    required String studentId,
    required String parentId,
    String? notes,
  }) async {
    try {
      print('📤 إرسال طلب خروج:');
      print('   studentId: $studentId');
      print('   parentId: $parentId');
      print('   notes: $notes');

      final response = await http.post(
        Uri.parse('$baseUrl/requests'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'parentId': parentId,
          'notes': notes,
        }),
      );

      print('📥 response status: ${response.statusCode}');
      print('📥 response body: ${response.body}');

      if (response.statusCode != 201) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل في إنشاء طلب الخروج';
        print('❌ error: $errorMessage');
        throw Exception(errorMessage);
      }

      print('✅ تم إرسال طلب الخروج بنجاح');
    } catch (error) {
      print('🔥 exception in createExitRequest: $error');
      rethrow;
    }
  }

  //تأكبد استلام الطالب
  static Future<void> completeRequest(String requestId) async {
    try {
      print('✅ محاولة تحديث الطلب: $requestId');

      final response = await http.put(
        Uri.parse('$baseUrl/requests/$requestId/complete'),
      );

      print('📊 حالة الرد: ${response.statusCode}');
      print('📦 محتوى الرد: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل في تحديث حالة الطلب';
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('❌ خطأ في completeRequest: $error');
      rethrow;
    }
  }

  // دالة استرجاع طلبات المدرسة
  static Future<List<ExitRequest>> getSchoolRequests(String schoolId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/schools/$schoolId/requests'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExitRequest.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل طلبات المدرسة: ${response.statusCode}');
    }
  }

  

  

}


