import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class Employee {
  final int id;
  final String email;
  final String name;
  final String title;

  Employee({
    required this.id,
    required this.email,
    required this.name,
    required this.title,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      title: json['title'],
    );
  }
}

class EmployeeService {
  final String baseUrl = globals.host + '/superAdmin';

  Future<List<Employee>> fetchEmployees() async {
    final response =
    await http.get(Uri.parse('$baseUrl/showEmployee'), headers: {
      'authorization': globals.token,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Employee> employees =
      jsonList.map((json) => Employee.fromJson(json)).toList();
      return employees;
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<http.Response> deleteEmployee(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteEmployee'),
      headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'id': id}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

  Future<void> createEmployee(
      String email, String password, int roleId, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/createEmployee'),
      headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'roleId': roleId,
        'name': name,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create employee');
    }
  }
}

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  late Future<List<Employee>> _employees;
  List<Employee> _employeeList = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees() {
    _employees = EmployeeService().fetchEmployees();
    _employees.then((employees) {
      setState(() {
        _employeeList = employees;
      });
    });
  }

  void _deleteEmployee(int id, int index) async {
    try {
      final response = await EmployeeService().deleteEmployee(id);
      if (response.statusCode == 200) {
        setState(() {
          _employeeList.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete employee')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee: $e')),
      );
    }
  }

  void _createEmployee(
      String email, String password, int roleId, String name) async {
    try {
      await EmployeeService().createEmployee(email, password, roleId, name);
      _loadEmployees();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create employee: $e')),
      );
    }
  }

  void _showCreateEmployeeDialog() {
    final _formKey = GlobalKey<FormState>();
    String email = '';
    String password = '';
    int roleId = 0;
    String name = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Employee'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onSaved: (value) => email = value!,
                  validator: (value) =>
                  value!.isEmpty ? 'Email is required' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  onSaved: (value) => password = value!,
                  validator: (value) =>
                  value!.isEmpty ? 'Password is required' : null,
                  obscureText: true,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Role ID'),
                  onSaved: (value) => roleId = int.parse(value!),
                  validator: (value) =>
                  value!.isEmpty ? 'Role ID is required' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onSaved: (value) => name = value!,
                  validator: (value) =>
                  value!.isEmpty ? 'Name is required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _createEmployee(email, password, roleId, name);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateEmployeeDialog,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Employee>>(
          future: _employees,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: _employeeList.length,
                itemBuilder: (context, index) {
                  var employee = _employeeList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${employee.name}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                SizedBox(height: 8),
                                Text('ID: ${employee.id}'),
                                SizedBox(height: 8),
                                Text('Email: ${employee.email}'),
                                SizedBox(height: 8),
                                Text('Title: ${employee.title}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEmployee(employee.id, index),
                          ),
                        ],
                      ),
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
    );
  }
}
