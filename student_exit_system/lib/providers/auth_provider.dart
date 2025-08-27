import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/student_model.dart';
import '../models/request_model.dart';


class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  String? _userPhone;
  bool _isAuthenticated = false;
  List<Student> _children = [];
  List<ExitRequest> _activeRequests = [];
  List<ExitRequest> get activeRequests => _activeRequests;


  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  List<Student> get children => _children;

  String? _schoolId;
  String? _schoolName;
  bool _isSchoolAuthenticated = false;

  bool get isSchoolAuthenticated => _isSchoolAuthenticated;
  String? get schoolId => _schoolId;
  String? get schoolName => _schoolName;

  

  // دالة تسجيل الدخول
  Future<void> login(String phoneNumber, String password) async {
    try {
      final response = await ApiService.login(phoneNumber, password);
    //  final loginResponse = LoginResponse.fromJson(response);

      _userId = response['user']['id'];
      _userName = response['user']['name'];
      _userPhone = response['user']['phoneNumber']; // احفظ رقم الجوال
      _children = (response['user']['children'] as List<dynamic>)
          .map((childJson) => Student.fromJson(childJson))
          .toList();
      _isAuthenticated = true;
      

      // حفظ بيانات الجلسة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _userId!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('userPhone', _userPhone!); // احفظ رقم الجوال
      await prefs.setBool('isAuthenticated', true);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // دالة تسجيل مستخدم جديد
  Future<void> register(
    String name,
    String phoneNumber,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        // تم التسجيل بنجاح، لا حاجة لتخزين responseData
        print('تم إنشاء الحساب بنجاح');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في التسجيل');
      }
    } catch (error) {
      throw error;
    }
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('isAuthenticated');

    notifyListeners();
  }

  // دالة التحقق من الجلسة المحفوظة
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('isAuthenticated') ?? false;

    if (isAuth) {
      _userId = prefs.getString('userId');
      _userName = prefs.getString('userName');
      _userPhone = prefs.getString('userPhone');
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // دالة دخول المدرسة
  Future<void> schoolLogin(String code, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/school-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _schoolId = responseData['school']['id'];
        _schoolName = responseData['school']['name'];
        _isSchoolAuthenticated = true;
        notifyListeners();
      } else {
        throw Exception('بيانات الدخول غير صحيحة');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> loadActiveRequests() async {
    try {
      // تحتاج إنشاء API جديد لاسترجاع طلبات ولي الأمر النشطة
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/parents/${_userId}/active-requests'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _activeRequests = data.map((json) => ExitRequest.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (error) {
      print('Error loading active requests: $error');
    }
  }
}


