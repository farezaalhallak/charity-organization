import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/widgets/visittime/uploadimage.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'form.dart';

// Model for Show Details
class ShowDetails {
  final String title;
  final String description;
  final String idKey;
  final String name;
  final String number;
  final String address;

  ShowDetails({
    required this.title,
    required this.description,
    required this.idKey,
    required this.name,
    required this.number,
    required this.address,
  });

  factory ShowDetails.fromJson(Map<String, dynamic> json) {
    return ShowDetails(
      title: json['title'],
      description: json['description1'],
      idKey: json['idKey'],
      name: json['name'],
      number: json['number'],
      address: json['address'],
    );
  }
}

// Fetch Show Details
Future<ShowDetails> fetchShowDetails(int id) async {
  final response = await http.post(
    Uri.parse(globals.host + '/visitedTeam/showDetails'),
    headers: {
      'authorization': globals.token,
      'Content-Type': 'application/json'
    },
    body: jsonEncode({'id': id}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return ShowDetails.fromJson(jsonData[0]);
  } else {
    throw Exception('Failed to load show details');
  }
}

// UI for Show Details Screen
class ShowDetailsScreen extends StatelessWidget {
  final int id;

  ShowDetailsScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Details'),
      ),
      body: FutureBuilder<ShowDetails>(
        future: fetchShowDetails(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load show details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No details found'));
          } else {
            final details = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Title'),
                    subtitle: Text(details.title),
                  ),
                  ListTile(
                    title: Text('Description'),
                    subtitle: Text(details.description),
                  ),
                  ListTile(
                    title: Text('ID Key'),
                    subtitle: Text(details.idKey),
                  ),
                  ListTile(
                    title: Text('Name'),
                    subtitle: Text(details.name),
                  ),
                  ListTile(
                    title: Text('Number'),
                    subtitle: Text(details.number),
                  ),
                  ListTile(
                    title: Text('Address'),
                    subtitle: Text(details.address),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadImageScreen(id: id),
                              ),
                            );
                          },
                          child: Text('Upload Images'),
                        ),
                      ),
                      SizedBox(width: 10), // Add space between the buttons
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormScreen(id: id),
                              ),
                            );
                          },
                          child: Text('Fill Form'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
