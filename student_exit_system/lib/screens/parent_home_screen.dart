import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/student_model.dart';
import 'request_exit_screen.dart';
import '../services/api_service.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<Student> _children = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      print('Loading children for phone: ${auth.userPhone}');

      //final children = await ApiService.getChildren(auth.userPhone!);

      setState(() {
        _children = auth.children;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading children: $error');

      final errorMessage = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: $errorMessage')),
      );

      setState(() => _isLoading = false);
    }
  }

  void _requestExit(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestExitScreen(student: student),
      ),
    );
  }


  Future<void> _completeRequest(String requestId) async {
    try {
      print('🎯 محاولة تأكيد الاستلام للطلب: $requestId');

      await ApiService.completeRequest(requestId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تأكيد الاستلام بنجاح')));
      _loadChildren();
    } catch (error) {
      print('💥 خطأ في التأكيد: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في التأكيد: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('الرئيسية - ولي الأمر'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _children.isEmpty
          ? Center(child: Text('لا يوجد أبناء مسجلين'))
          : ListView.builder(
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final student = _children[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.person, size: 40),
                    title: Text(student.name, style: TextStyle(fontSize: 18)),
                    subtitle: Text(
                      'الصف: ${student.grade} - الفصل: ${student.className}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر طلب خروج
                        ElevatedButton(
                          onPressed: () => _requestExit(student),
                          child: Text('طلب خروج'),
                        ),
                        SizedBox(width: 8),
                        // زر تم الاستلام (إذا كان هناك طلب active)
                        ElevatedButton(
                          onPressed: () => _completeRequest(
                            'request_id_here',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ), // تحتاج معرفة ID الطلب
                          child: Text('تم الاستلام'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
