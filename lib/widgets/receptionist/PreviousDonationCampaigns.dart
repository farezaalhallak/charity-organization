import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/widgets/receptionist/main4.dart';
import 'dart:convert';
import '../../globals.dart' as globals;
import 'donationCampaigns.dart';


Future<void> _navigateToDetails(int id,BuildContext context,int userId) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>DonationCampaignsScreenn(id: id,userId: userId,),
    ),
  );
}
class PreviousDonationRequest {
  final int id;
  final String title;
  final int status;

  PreviousDonationRequest({
    required this.id,
    required this.title,
    required this.status,
  });

  factory PreviousDonationRequest.fromJson(Map<String, dynamic> json) {
    return PreviousDonationRequest(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation Campaigns',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PreviousDonationCampaignsScreen(),
    );
  }
}

class PreviousDonationCampaignsScreen extends StatefulWidget {
  @override
  _PreviousDonationCampaignsScreenState createState() => _PreviousDonationCampaignsScreenState();
}

class _PreviousDonationCampaignsScreenState extends State<PreviousDonationCampaignsScreen> {
  final TextEditingController _idUserController = TextEditingController(text: globals.userId);
  late List<PreviousDonationRequest> _responseMessage =[];

  Future<void> _fetchPreviousDonationCampaigns() async {
    final String idUser = _idUserController.text;


    final Uri url = Uri.parse(globals.host+'/receptionist/previousDonationCampaigns');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'
        ,'authorization': globals.token,
        },
        body: jsonEncode({'idUser': idUser}),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<PreviousDonationRequest> previousDonationRequests = jsonResponse
            .map((e) => PreviousDonationRequest.fromJson(e))
            .toList();
        setState(() {
          _responseMessage = previousDonationRequests;
        });
      } else {
        setState(() {
        });
      }
    } catch (e) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Donation Campaigns'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _idUserController,
              decoration: InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchPreviousDonationCampaigns,
              child: Text('Fetch Campaigns'),
            ),
            SizedBox(height: 16.0),
        Expanded(
          child:
       ListView.builder(
                  itemCount: _responseMessage.length,
                  itemBuilder: (context, index) {
                    final request = _responseMessage[index];
                    return Card(
                      elevation: 4, // Adjust the shadow elevation here
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () {

                           _navigateToDetails( request.id,context,int.parse(_idUserController.text) as int);
                           print("_navigateToDetails " );

                        },
                        contentPadding: EdgeInsets.all(16),
                        title: Text('ID: ${request.id}',
                        ),
                        subtitle: Text('Title: ${request.title}'),
                        trailing: Text('Status: ${request.status}'),

                      ),
                    );
                  },
                ),

        ),


          ],
        ),
      ),
    );
  }
}
