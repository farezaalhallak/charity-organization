import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'getAdminPermissions.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? token;

  @override
  void initState() {
    super.initState();

  }

  Future<void> login() async {
    final url = Uri.parse(globals.host + '/admin/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    // طباعة حالة الاستجابة ورمز الاستجابة على الـ Console
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];

      setState(() {
        this.token = token;
        globals.token = "bearer " + token;
      });

      // التنقل إلى شاشة الصلاحيات مباشرةً
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdminPermissionsScreen()),
      );
    } else {
      // التعامل مع حالة فشل تسجيل الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await login();
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
