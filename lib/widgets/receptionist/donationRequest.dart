import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../globals.dart' as globals; // Assuming globals contains the base URL and token

class DonationRequest {
  final int id;
  final int campaignId;
  final String imageUrl;
  final double cost;
  final DateTime createDate;

  DonationRequest({
    required this.id,
    required this.campaignId,
    required this.imageUrl,
    required this.cost,
    required this.createDate,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['id'] ?? 0,
      campaignId: json['requestid'] ?? 0,
      imageUrl: json['imageurl'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      createDate: DateTime.parse(json['createDate'] ?? ''),
    );
  }
}

class DonationRequestsScreenn extends StatefulWidget {
  int id ;
  int userId ;
  DonationRequestsScreenn({required int this.id ,required int this.userId});
  @override
  _DonationRequestsScreennState createState() =>
      _DonationRequestsScreennState(id : this.id,userId:this.userId );
}

class _DonationRequestsScreennState extends State<DonationRequestsScreenn> {
  _DonationRequestsScreennState({required int id ,required int userId});

  final String baseUrl = globals.host + '/receptionist/donationRequest';
  List<DonationRequest> _DonationRequests = [];
  bool _isLoading = false;
  TextEditingController _idController = TextEditingController();
  TextEditingController _idUserController = TextEditingController(text: globals.userId);

  Future<void> _fetchDonationRequests(int id, int idUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'idUser': idUser,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<DonationRequest> DonationRequests = jsonResponse
            .map((e) => DonationRequest.fromJson(e))
            .toList();
        setState(() {
          _DonationRequests = DonationRequests;
        });
      } else {
        throw Exception('Failed to load donation campaigns');
      }
    } catch (e) {
      print('Error fetching donation campaigns: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Campaigns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           /* TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Enter ID',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _idUserController,
              decoration: InputDecoration(
                labelText: 'Enter User ID',
              ),
              keyboardType: TextInputType.number,
            ),*/
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //final id = int.tryParse(_idController.text);
               // final idUser = int.tryParse(_idUserController.text);

                  _fetchDonationRequests(widget.id, widget.userId);

                  // Handle invalid input

              },
              child: Text('Fetch Donation Campaigns'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _DonationRequests.isEmpty
                ? Center(child: Text('No donation campaigns found'))
                : Expanded(

                    child:ListView.builder(
                     itemCount: _DonationRequests.length,
                       itemBuilder: (context, index) {

                        return Column(
                          children:[
                              Image.network(
                           globals.host +
                               '/' +
                               _DonationRequests[index]
                                   .imageUrl,
                           fit: BoxFit.cover,
                         ),

                          Text(
                         'Campaign ID: ${_DonationRequests[index].campaignId}'),

                         Text(
                         'Cost: \$${_DonationRequests[index].cost}'),
                         Text(
                         'Date: ${_DonationRequests[index].createDate.toLocal().toString().split(' ')[0]}'),



                       ],
                         );
                       }


            ),
            ),
        ])
      ),
    );
  }
}
