import 'dart:convert';
import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  List<Map<String, dynamic>> aboutUsData = [
    {
      "text1": "text1",
      "text2": "text2",
      "text3": "text3",
      "text4": "text4",
      "text5": "text5",
      "contactUs": "contactUs",
    }
  ];
  Map<String, TextEditingController> controllers = {};
  Map<String, bool> isEditing = {};

  @override
  void initState() {
    super.initState();
    fetchAboutUsData();
  }

  Future<void> fetchAboutUsData() async {
    try {
      final url = Uri.parse(globals.host + '/mediaTeam/aboutUs');
      final response = await http.get(url, headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json',
      });

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          setState(() {
            aboutUsData = List<Map<String, dynamic>>.from(jsonResponse);
            aboutUsData.forEach((data) {
              controllers['text1'] =
                  TextEditingController(text: data['text1'] ?? '');
              controllers['text2'] =
                  TextEditingController(text: data['text2'] ?? '');
              controllers['text3'] =
                  TextEditingController(text: data['text3'] ?? '');
              controllers['text4'] =
                  TextEditingController(text: data['text4'] ?? '');
              controllers['text5'] =
                  TextEditingController(text: data['text5'] ?? '');
              controllers['contactUs'] =
                  TextEditingController(text: data['contactUs'] ?? '');
              isEditing['text1'] = false;
              isEditing['text2'] = false;
              isEditing['text3'] = false;
              isEditing['text4'] = false;
              isEditing['text5'] = false;
              isEditing['contactUs'] = false;
            });
          });
        } else if (jsonResponse is Map<String, dynamic>) {
          setState(() {
            aboutUsData = [jsonResponse];
            controllers['text1'] =
                TextEditingController(text: jsonResponse['text1'] ?? '');
            controllers['text2'] =
                TextEditingController(text: jsonResponse['text2'] ?? '');
            controllers['text3'] =
                TextEditingController(text: jsonResponse['text3'] ?? '');
            controllers['text4'] =
                TextEditingController(text: jsonResponse['text4'] ?? '');
            controllers['text5'] =
                TextEditingController(text: jsonResponse['text5'] ?? '');
            controllers['contactUs'] =
                TextEditingController(text: jsonResponse['contactUs'] ?? '');
            isEditing['text1'] = false;
            isEditing['text2'] = false;
            isEditing['text3'] = false;
            isEditing['text4'] = false;
            isEditing['text5'] = false;
            isEditing['contactUs'] = false;
          });
        }
      } else {
        print('Error fetching about us data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching about us data: $e');
    }
  }

  Future<void> editAboutUsData() async {
    try {
      final url = Uri.parse(globals.host + '/mediaTeam/editAboutUs');
      final updatedData = {
        'text1': controllers['text1']!.text,
        'text2': controllers['text2']!.text,
        'text3': controllers['text3']!.text,
        'text4': controllers['text4']!.text,
        'text5': controllers['text5']!.text,
        'contactUs': controllers['contactUs']!.text,
      };

      final response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      print('Edit response status code: ${response.statusCode}');
      print('Edit response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          isEditing.forEach((key, value) {
            isEditing[key] = false;
          });
          aboutUsData[0] = updatedData;
        });
      } else {
        print('Error editing about us data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error editing about us data: $e');
    }
  }

  Widget buildEditableText(String key, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isEditing[key]!
            ? Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers[key],
                decoration: InputDecoration(labelText: label),
              ),
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.black),
              onPressed: () {
                setState(() {
                  editAboutUsData();
                });
              },
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: Text(
                controllers[key]!.text,
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                setState(() {
                  isEditing[key] = true;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: aboutUsData.isNotEmpty
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: aboutUsData.map((data) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(globals.host + "/" + (data['imageUrl'] ?? '')),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  buildEditableText('text1', 'Text 1'),
                  buildEditableText('text2', 'Text 2'),
                  buildEditableText('text3', 'Text 3'),
                  buildEditableText('text4', 'Text 4'),
                  buildEditableText('text5', 'Text 5'),
                  buildEditableText('contactUs', 'Contact Us'),
                ],
              );
            }).toList(),
          ),
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
