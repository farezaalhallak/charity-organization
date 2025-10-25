import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class DecreaseFundScreen extends StatefulWidget {
  @override
  _DecreaseFundScreenState createState() => _DecreaseFundScreenState();
}

class _DecreaseFundScreenState extends State<DecreaseFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countController = TextEditingController();
  final _reasonController = TextEditingController();
  String _message = '';

  Future<void> _decreaseFund() async {
    if (_formKey.currentState?.validate() ?? false) {
      final count = _countController.text;
      final reason = _reasonController.text;

      final String url = globals.host + '/superAdmin/decreaseFund';

      try {
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode({
            'count': count,
            'reason': reason,
          }),
          headers: {
            'authorization': globals.token,
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'Decrease fund successful!';
          });
        } else {
          setState(() {
            _message = 'Failed to decrease fund: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Error decreasing fund: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decrease Fund'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Count'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a count';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(labelText: 'Reason'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _decreaseFund,
                    child: Text('Submit'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _message,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
