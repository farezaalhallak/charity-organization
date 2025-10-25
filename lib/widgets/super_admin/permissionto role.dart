import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class RolePermissionScreen extends StatefulWidget {
  final int roleId;

  RolePermissionScreen({required this.roleId});

  @override
  _RolePermissionScreenState createState() => _RolePermissionScreenState();
}

class _RolePermissionScreenState extends State<RolePermissionScreen> {
   bool containsid(final List<Permission> list, final int id){
     bool isExist = false ;
     list.forEach((item){

       if(item.id == id){
         isExist = true;
       }
     });
    return isExist;
    }
  late List<Permission> _permissions;
  late Future<List<Permission2>>  _All_permissions ;

  String? _errorMessage;
  List<int> addedPermissions = []; // List to keep track of added permissions

  @override
  void initState() {
    super.initState();
    fetchPermissions(widget.roleId);
    //_permissions = fetchPermissions(widget.roleId);
    _All_permissions =fetchAllPermissions();
  }

  Future<List<Permission>> fetchPermissions(int roleId) async {
    try {
      final response = await http.post(
        Uri.parse(globals.host + '/superAdmin/showRolePermisions'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'id': roleId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        _permissions = list.map((model) => Permission.fromJson(model)).toList();
        return list.map((model) => Permission.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load permissions: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching permissions: $e";
      });
      print(_errorMessage);
      return [];
    }
  }
  Future<List<Permission2>> fetchAllPermissions() async {
    try {
      final response = await http.get(
        Uri.parse(globals.host + '/superAdmin/showPermissions'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },

      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        return list.map((model) => Permission2.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load permissions: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching permissions: $e";
      });
      print(_errorMessage);
      return [];
    }
  }
  Future<void> deletePermission(int permissionId) async {
    try {
      final response = await http.post(
        Uri.parse(globals.host + '/superAdmin/deletePermissionFromRole'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body:
            jsonEncode({'permissionId': permissionId, 'roleId': widget.roleId}),
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        // Refresh the permissions list
        setState(() {
          // fetchPermissions(widget.roleId);
         // _All_permissions =fetchAllPermissions();

        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission deleted successfully'),
          ),
        );
      } else {
        throw Exception(
            'Failed to delete permission: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error deleting permission: $e";
      });
      print(_errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting permission: $e'),
        ),
      );
    }
  }

  Future<void> addPermission(int permissionId) async {
    try {
      final response = await http.post(
        Uri.parse(globals.host + '/superAdmin/addPermissionToRole'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body:
            jsonEncode({'permissionId': permissionId, 'roleId': widget.roleId}),
      );

      print('Add response status: ${response.statusCode}');
      print('Add response body: ${response.body}');

      if (response.statusCode == 200) {
        // Add permission to the addedPermissions list
        setState(() {
          addedPermissions.add(permissionId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission added successfully'),
          ),
        );
      } else {
        throw Exception('Failed to add permission: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error adding permission: $e";
      });
      print(_errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding permission: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role Permissions'),
      ),
      body:Center(
      child:

         FutureBuilder<List<Permission2>>(
          future: _All_permissions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(_errorMessage ?? "Failed to load permissions");
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final permission = snapshot.data![index];
                  final isAdded = addedPermissions.contains(permission.id);
                  return ListTile(
                    title: Text(permission.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        containsid(_permissions,permission.id)?
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletePermission(permission.id),
                        ):
                        IconButton(
                          icon: Icon(isAdded ? Icons.check : Icons.add,
                              color: Colors.green),
                          onPressed: isAdded
                              ? null
                              : () => addPermission(permission.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Text("No permissions found");
            }
          },
        ),
        /* FutureBuilder<List<Permission>>(
          future: _All_permissions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(_errorMessage ?? "Failed to load permissions");
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final permission = snapshot.data![index];
                  final isAdded = addedPermissions.contains(permission.id);
                  return ListTile(
                    title: Text(permission.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       /* IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletePermission(permission.id),
                        ),*/
                        IconButton(
                          icon: Icon(isAdded ? Icons.check : Icons.add,
                              color: Colors.green),
                          onPressed: isAdded
                              ? null
                              : () => addPermission(permission.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Text("No permissions found");
            }
          },
        ),*/
        ),
    );
  }
}
class Permission2 {
  final int id;
  final String title;

  Permission2({
    required this.id,
    required this.title,
  });

  factory Permission2.fromJson(Map<String, dynamic> json) {
    return Permission2(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}
class Permission {
  final int id;
  final String name;

  Permission({
    required this.id,
    required this.name,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['permissionid'] ?? 0,
      name: json['permisiontitle'] ?? '',
    );
  }
}
