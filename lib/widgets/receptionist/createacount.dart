import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _id = '';
  String _name = '';
  String _email = '';
  String _password = '';
  String _fullNumber = '';
  String _dateOfBirth = '';
  String _address = '';

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // تأكد من أن 'id' هو int
      final int? id = int.tryParse(_id);
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid ID format'),
          ),
        );
        return;
      }

      final String name = _name;
      final String email = _email;
      final String password = _password;
      final String fullNumber = _fullNumber;
      final String dateOfBirth = _dateOfBirth;
      final String address = _address;

      // طباعة للتأكد من الأنواع
      print('id (int): $id');
      print('name (String): $name');
      print('email (String): $email');
      print('password (String): $password');
      print('fullNumber (String): $fullNumber');
      print('dateOfBirth (String): $dateOfBirth');
      print('address (String): $address');

      final url = Uri.parse(globals.host + '/receptionist/createAccount');
      final body = jsonEncode({
        'id': id,
        'name': name,
        'Email': email,
        'password': password,
        'fullNumber': fullNumber,
        'Date': dateOfBirth,
        'addr': address,
      });

      print('Request Body: $body');

      try {
        final response = await http.post(url, body: body, headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        });
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Account created with ID: ${responseData[0]['id']}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating account'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating account: $e'),
          ),
        );
        print('Error creating account: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _id,
                decoration: InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  _id = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a full number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fullNumber = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: _dateOfBirth,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a date of birth';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dateOfBirth = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value!;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createAccount,
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
