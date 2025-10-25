import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

// Model class for Permission
class Permission {
  final int id;
  final String title;
  final String createDate; // Added createDate field

  Permission({
    required this.id,
    required this.title,
    required this.createDate,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      title: json['title'],
      createDate: json['createDate'],
    );
  }
}

// Service class for managing permissions
class PermissionService {
  final String baseUrl = globals.host + '/superAdmin/showPermissions';
  final String postUrl = globals.host + '/superAdmin/showRolePermissions';

  Future<List<Permission>> fetchPermissions() async {
    final response = await http.get(Uri.parse(baseUrl), headers: {
      'authorization': globals.token,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Permission.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load permissions');
    }
  }

  Future<String> sendRolePermission(int id, String role) async {
    final response = await http.post(
      Uri.parse(postUrl),
      headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json',
      },
      body: json.encode({'id': id, 'description': role}),
    );

    if (response.statusCode == 200) {
      return 'Role permissions sent successfully';
    } else {
      throw Exception('Failed to send role permissions');
    }
  }
}

class PermissionScreen extends StatefulWidget {
  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late Future<List<Permission>> _permissions;
  final String _defaultRole =
      'DefaultRole'; // Use a default role or fetch from somewhere else

  @override
  void initState() {
    super.initState();
    _permissions = PermissionService().fetchPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions'),
      ),
      body: FutureBuilder<List<Permission>>(
        future: _permissions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final permission = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(permission.title),
                    subtitle: Text('Created: ${permission.createDate}'),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
