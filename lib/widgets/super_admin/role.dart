import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:untitled/widgets/super_admin/permission.dart';
import 'package:untitled/widgets/super_admin/permissionto%20role.dart';

class Role {
  final int id;
  final String title;

  Role({required this.id, required this.title});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      title: json['title'],
    );
  }
}

class RoleService {
  final String baseUrl = globals.host + '/superAdmin/showRole';
  final String createRoleUrl = globals.host + '/superAdmin/createRole';

  Future<List<Role>> fetchRoles() async {
    final response = await http.get(Uri.parse(baseUrl), headers: {
      'authorization': globals.token,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Role.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load roles');
    }
  }

  Future<void> createRole(String title) async {
    final response = await http.post(
      Uri.parse(createRoleUrl),
      headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json',
      },
      body: json.encode({'title': title}),
    );

    if (response.statusCode == 200) {
      print('Role created successfully');
    } else {
      throw Exception('Failed to create role');
    }
  }
}

class RoleScreen extends StatefulWidget {
  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  late Future<List<Role>> _roles;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roles = RoleService().fetchRoles();
  }

  void _handleCreateRole() {
    final title = _titleController.text;
    if (title.isNotEmpty) {
      RoleService().createRole(title).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role created successfully')),
        );
        setState(() {
          _roles = RoleService()
              .fetchRoles(); // Refresh the list after creating a role
        });
        _titleController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create role: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
    }
  }

  void _handleRoleTap(Role role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RolePermissionScreen(roleId: role.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Role Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _handleCreateRole,
            child: Text('Create Role'),
          ),
          Expanded(
            child: Center(
              child: FutureBuilder<List<Role>>(
                future: _roles,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final role = snapshot.data![index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              role.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),

                            ),
                            subtitle:  Text(
                            role.id.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),

                          ) ,
                            onTap: () => _handleRoleTap(role),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
