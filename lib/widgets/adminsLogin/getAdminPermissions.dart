import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled/widgets/mediaTeam/main3.dart';
import '../receptionist/main4.dart'; // استيراد الشاشة المراد الانتقال إليها

import '../../seconde.dart';
import '../store/main2.dart';
import '../super_admin/main5.dart';
import '../visittime/mainvisit.dart'; // استيراد الشاشة المراد الانتقال إليها

class AdminPermissionsScreen extends StatefulWidget {
  @override
  _AdminPermissionsScreenState createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  List<dynamic> permissions = [];
  Set<String> uniqueTitles = {}; // لتخزين الكلمات الفريدة

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    final url = Uri.parse(globals.host + '/admin/getAdminPermissions');
    final response = await http.get(url, headers: {
      'authorization': globals.token,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        permissions = data;

        // استخراج الكلمات الأولى الفريدة من العناوين
        uniqueTitles = permissions.map((perm) {
          final title = perm['title'] as String;
          final firstWord = title.split(' ').first;
          return firstWord;
        }).toSet();
      });
    } else {
      throw Exception('Failed to load permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Permissions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: permissions.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                final permission = permissions[index];
                return ListTile(
                  title: Text(permission['title']),
                  subtitle: Text('Permission ID: ${permission['permissionId']}'),
                );
              },
            ),
          ),
          // بناء الأزرار بناءً على الكلمات الأولى الفريدة
          if (uniqueTitles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: uniqueTitles.map((title) {
                  // اختيار الشاشة المناسبة بناءً على الكلمة
                  Widget targetScreen;
                  if (title == 'receptionist') {
                    targetScreen = Main4();
                  } else if (title == 'superAdmin') {
                    targetScreen = Main5();
                  } else if (title == 'media') {
                    targetScreen = Main3();
                  } else if (title == 'visited') {
                    targetScreen = Mainvisit();
                  }  else if (title == 'store') {
                    targetScreen = Main2();
                  }
                  else {
                    targetScreen = MyApp3();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => targetScreen),
                        );
                      },
                      child: Text(title),
                    ),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp3()),
                );
              },
              child: Text('Ok'),
            ),
          ),
        ],
      ),
    );
  }
}

