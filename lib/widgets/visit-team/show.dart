import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:untitled/const/colors.dart';
import 'package:untitled/widgets/visittime/showdetials.dart';
import '../../globals.dart' as globals;

// Model for Show
class Show {
  final int id;
  final String title;
  final int requestId;
  final DateTime dayDate;
  final int dateInteger;

  Show({
    required this.id,
    required this.title,
    required this.requestId,
    required this.dayDate,
    required this.dateInteger,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'],
      title: json['title'],
      requestId: json['requestid'],
      dayDate: DateTime.parse(json['dayDate']),
      dateInteger: json['dateInteger'],
    );
  }
}

// Fetch Shows
Future<List<Show>> fetchShows() async {
  final response = await http.get(Uri.parse(globals.host + '/visitedTeam/show'),
      headers: {
        'authorization': globals.token,
        'authorization': globals.token
      });

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((dynamic item) => Show.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load shows');
  }
}

// UI for Shows Screen
class ShowsScreen extends StatefulWidget {
  @override
  _ShowsScreenState createState() => _ShowsScreenState();
}

class _ShowsScreenState extends State<ShowsScreen> {
  late Future<List<Show>> futureShows;

  @override
  void initState() {
    super.initState();
    futureShows = fetchShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenLight,
      appBar: AppBar(
        backgroundColor: AppColors.greenLight,
        title: Center(
          child: Text(
            'Shows',
            style: TextStyle(
              fontSize: 20, // Adjust font size if needed
              fontWeight: FontWeight.bold, // Adjust font weight if needed
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Show>>(
        future: futureShows,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load shows'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No shows found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final show = snapshot.data![index];
                return Center(
                  child: Card(
                    color: Colors.white,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: ListTile(
                      title: Text(show.title), // Display the title
                      subtitle:
                          Text('From: ${show.dayDate} To: ${show.dateInteger}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShowDetailsScreen(id: show.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
