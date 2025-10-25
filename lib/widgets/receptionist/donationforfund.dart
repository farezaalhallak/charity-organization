import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class DonationForFundScreen extends StatefulWidget {
  @override
  _DonationForFundScreenState createState() => _DonationForFundScreenState();
}

class _DonationForFundScreenState extends State<DonationForFundScreen> {
  final String donationUrl = '${globals.host}/receptionist/donationForFund';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController(text: globals.userId);
  bool _isLoading = false;

  Future<void> _submitDonation() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(donationUrl),
          body: jsonEncode({
            'amount': _amountController.text,
            'idUser': _userIdController.text,
          }),
          headers: {
            'authorization': globals.token,
            'Content-Type': 'application/json',
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          _showSuccessDialog();
        } else {
          final responseBody = jsonDecode(response.body);
          _showErrorDialog(responseBody['error'] ?? 'An unknown error occurred.');
        }
      } catch (e) {
        print('Error processing donation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process donation: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Donation successful'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Return to the previous screen and pass a result
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
        title: Text('Donate to Fund'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'User ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your User ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitDonation,
                child: Text('Submit Donation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
