import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SchoolLoginScreen extends StatefulWidget {
  const SchoolLoginScreen({super.key});

  @override
  _SchoolLoginScreenState createState() => _SchoolLoginScreenState();
}

class _SchoolLoginScreenState extends State<SchoolLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).schoolLogin(_schoolCodeController.text, _passwordController.text);

      Navigator.pushReplacementNamed(context, '/school');
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في الدخول: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دخول المدرسة'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار المدرسة
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 20),
              const Text(
                'دخول إدارة المدرسة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // حقل كود المدرسة
              TextFormField(
                controller: _schoolCodeController,
                decoration: const InputDecoration(
                  labelText: 'كود المدرسة',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كود المدرسة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // حقل كلمة المرور
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // زر الدخول
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('دخول', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
