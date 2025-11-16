import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/student_model.dart';

class RequestExitScreen extends StatefulWidget {
  final Student student;

  const RequestExitScreen({super.key, required this.student});

  @override
  _RequestExitScreenState createState() => _RequestExitScreenState();
}

class _RequestExitScreenState extends State<RequestExitScreen> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

 Future<void> _submitRequest() async {
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      print('🎯 بدء إرسال طلب الخروج:');
      print('   student.id: ${widget.student.id}');
      print('   auth.userId: ${auth.userId}');
      print('   auth.userPhone: ${auth.userPhone}');

      await ApiService.createExitRequest(
        studentId: widget.student.id,
        parentId: auth.userId!,
        notes: _notesController.text,
      );

      print('🎉 تم إرسال الطلب بنجاح');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الخروج بنجاح')),
      );
      Navigator.pop(context);
    } catch (error) {
      print('💥 خطأ في _submitRequest: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في إرسال الطلب: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب خروج الطالب'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(widget.student.name),
                subtitle: Text('الرقم الجامعي: ${widget.student.studentId}'),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 30),

            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'إرسال طلب الخروج',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
