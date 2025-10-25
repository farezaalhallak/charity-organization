import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class DonationScreen extends StatefulWidget {
  final int campaignId;

  DonationScreen({required this.campaignId});

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final String donationUrl =
      globals.host + '/receptionist/donationForCamoaugns';
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
            'id': widget.campaignId.toString(),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Donation successful')),
          );
          Navigator.pop(context);
        } else {
          throw Exception(
              'Failed to process donation. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error processing donation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process donation: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate to Campaign'),
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
