import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../globals.dart' as globals;

import 'package:untitled/const/colors.dart';

class ChargeScreen extends StatefulWidget {
  @override
  _ChargeScreenState createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final TextEditingController _idKeyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;

  Future<void> _chargeAmount() async {
    final String idKey = _idKeyController.text.trim();
    final String amount = _amountController.text.trim();

    if (idKey.isEmpty || amount.isEmpty) {
      _showDialog('Error', 'Please fill in both fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(globals.host+'/receptionist/charge'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idkey': idKey,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        _showDialog('Success', 'Charge successful!');
      } else {
        _showDialog(
            'Error', 'Failed to charge. Server responded with status code ${response.statusCode}.');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to charge: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: Text('Charge Amount'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _idKeyController,
                decoration: InputDecoration(
                  labelText: 'ID Key',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 40),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _chargeAmount,
              child: Text('Charge'),
            ),
          ],
        ),
      ),
    );
  }
}
