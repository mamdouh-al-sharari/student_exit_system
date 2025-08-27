import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/request_model.dart';
import '../models/student_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SchoolDashboardScreen extends StatefulWidget {
  const SchoolDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SchoolDashboardScreen> createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen> {
  List<ExitRequest> _requests = [];
  List<Student> _students = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  final String schoolId = '68ac239e61bc285e5f519e8e';
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
  int _previousRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final requests = await ApiService.getSchoolRequests(schoolId);
      final students = await _loadStudents();

      if (mounted) {
        setState(() {
          _previousRequestCount = _requests.length;
          _requests = requests;
          _students = students;
          _isLoading = false;
        });

        if (requests.length > _previousRequestCount) {
          _scrollToBottom();
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<List<Student>> _loadStudents() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/schools/$schoolId/students'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل الطلاب');
      }
    } catch (error) {
      throw error;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المدرسة'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex == 0
          ? _buildRequestsList()
          : _buildStudentsList(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'طلبات الخروج',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'الطلاب'),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return _requests.isEmpty
        ? const Center(child: Text('لا توجد طلبات خروج حالية'))
        : ListView.builder(
           controller: _scrollController,
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, size: 40),
                  title: Text(
                    request.studentName.isNotEmpty
                        ? request.studentName
                        : 'فهد ممدوح', // اسم افتراضي
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الحالة: ${request.status}'),
                      if (request.notes != null && request.notes!.isNotEmpty)
                        Text('ملاحظات: ${request.notes}'),
                      Text('الوقت: ${_formatTime(request.requestedAt)}'),
                    ],
                  ),
                ),
              );
            },
          );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStudentsList() {
    return _students.isEmpty
        ? const Center(child: Text('لا يوجد طلاب مسجلين'))
        : ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, size: 40),
                  title: Text(
                    student.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رقم الطالب: ${student.studentId}'),
                      Text(
                        'الصف: ${student.grade} - الفصل: ${student.className}',
                      ),
                      Text('ولي الأمر: ${student.parentPhone}'),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
