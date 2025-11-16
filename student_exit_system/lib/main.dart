import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/parent_home_screen.dart';
import 'screens/school_dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import 'screens/school_login_screen.dart'; // أضف هذا
 // أضف هذا الاستيراد

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'نظام طلب خروج الطلاب',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.green, 
          ),
          fontFamily: 'Cairo',
        ),
        home: WelcomeScreen(), 
        routes: {
          '/welcome': (context) => WelcomeScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/school-login': (context) => const SchoolLoginScreen(),
          '/parent': (context) => ParentHomeScreen(),
          '/school': (context) => SchoolDashboardScreen(),
        },
      ),
    );
  }
}
