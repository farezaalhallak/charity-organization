import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../const/colors.dart';

class FormScreen extends StatefulWidget {
  final int id;

  FormScreen({required this.id});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = [];
  List<Map<String, dynamic>> formTitles = [];

  @override
  void initState() {
    super.initState();
    fetchFormTitles();
  }

  Future<void> fetchFormTitles() async {
    try {
      var response =
      await http.get(Uri.parse(globals.host + '/visitedTeam/showForm'), headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json'
      });
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          formTitles = List<Map<String, dynamic>>.from(data);
          _controllers = List.generate(
              formTitles.length, (index) => TextEditingController());
        });
      } else {
        print('Failed to load form titles: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error loading form titles: $e');
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      List<Map<String, dynamic>> answers = [];
      for (int i = 0; i < _controllers.length; i++) {
        answers.add({
          'idRequest': widget.id,
          'idFormItem': formTitles[i]['id'],
          'answer': _controllers[i].text,
        });
      }

      try {
        var response = await http.post(
          Uri.parse(globals.host + '/visitedTeam/enterForm'),
          headers: {
            'authorization': globals.token,
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'answers': answers}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('Failed to submit form: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenLight,
      appBar: AppBar(
        backgroundColor: AppColors.greenLight,
        title: Center(
          child: Text(
            'Form Submission',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: formTitles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: formTitles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 80),
                          child: TextFormField(
                            controller: _controllers[index],
                            decoration: InputDecoration(
                              labelText:
                              'Enter answer for ${formTitles[index]['title']}',
                              hintText: 'Answer ${index + 1}',
                              filled: true,
                              fillColor: AppColors.lightGreen,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(
                        height:
                        15), // Adjust space between the last form field and the button
                    Center(
                      child: ElevatedButton(
                        onPressed: submitForm,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              AppColors.greenDark), // Background color
                          foregroundColor: MaterialStateProperty.all(
                              Colors.white), // Text color
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Circular border radius
                            ),
                          ),
                        ),
                        child: Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
