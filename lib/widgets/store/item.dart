import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../../const/colors.dart';

class Items extends StatefulWidget {
  final int subCategoryId;

  Items({required this.subCategoryId});

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _countController = TextEditingController();
  TextEditingController titleController =
  TextEditingController();
  TextEditingController countController =
  TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      var url = Uri.parse(globals.host + '/store/storeItem');
      var body = jsonEncode({"id": widget.subCategoryId});

      var response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('Response data: $data');

        setState(() {
          items = List<Map<String, dynamic>>.from(data.map((item) => {
                'id': item['id'],
                'title': item['title'],
                'count': item['count'],
              }));
          isLoading = false;
        });

        if (items.isEmpty) {
          print('No items found for subCategoryId: ${widget.subCategoryId}');
        }
      } else {
        print('Failed to load items. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addItem() async {
    try {
      var url = Uri.parse(globals.host + '/store/addItem');
      var body = jsonEncode({
        "id": widget.subCategoryId,
        "title": titleController.text,
        "count": int.parse(countController.text),
      });

      var response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Item added successfully');
        titleController.clear();
        countController.clear();
        fetchItems(); // Refresh the items list
      } else {
        print('Failed to add item. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Future<void> addExistingItem(int itemId, int count) async {
    try {
      var url = Uri.parse(globals.host + '/store/addExistingItem');
      var body = jsonEncode({
        "id": itemId,
        "count": count,
      });

      var response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Existing item count updated successfully');
        fetchItems(); // Refresh the items list
      } else {
        print(
            'Failed to update existing item. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating existing item: $e');
    }
  }

  Future<void> decreaseExistingItem(int itemId, int count) async {
    try {
      var url = Uri.parse(globals.host + '/store/DecreaseExistingItem');
      var body = jsonEncode({
        "id": itemId,
        "count": count,
      });

      var response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Existing item count decreased successfully');
        fetchItems(); // Refresh the items list
      } else {
        print(
            'Failed to decrease existing item. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error decreasing existing item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor:  AppColors.greenLight,
      appBar: AppBar(backgroundColor:  AppColors.greenLight,
        title: Text('Items'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : items.isEmpty
              ?Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            children:
                [
            Center(child: Text('No items available')),
        IconButton(
        icon: Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {

                return AlertDialog(
                  title:
                  Text('Add item'),
                  content:
                Column(
                children:[
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                        hintText: 'item Title'),
                  ),
                  TextField(
                    controller: countController,
                    decoration: InputDecoration(
                        hintText: 'count'),
                  ),
                ]),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {

                          addItem();
                          Navigator.of(context).pop();

                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
      ),]))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, size: 50.0,color: Colors.black,),
                        onPressed: () {
                          // Show dialog to add category
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {

                              return AlertDialog(
                                title:
                                Text('Add item'),
                                content:
                                Column(
                                    children:[
                                      TextField(
                                        controller: titleController,
                                        decoration: InputDecoration(
                                            hintText: 'item Title'),
                                      ),
                                      TextField(
                                        controller: countController,
                                        decoration: InputDecoration(
                                            hintText: 'count'),
                                      ),
                                    ]),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {

                                      addItem();
                                      Navigator.of(context).pop();

                                    },
                                    child: Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              shadowColor: Colors.grey,
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                title: Text(
                                  items[index]['title'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text('Count: ${items[index]['count']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            int newCount =
                                                items[index]['count'];
                                            TextEditingController
                                                _countController =
                                                TextEditingController(
                                                    text: newCount.toString());
                                            return AlertDialog(
                                              title: Text('Update Item Count'),
                                              content: TextField(
                                                controller: _countController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Item Count',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    int newCount = int.parse(
                                                        _countController.text);
                                                    addExistingItem(
                                                        items[index]['id'],
                                                        newCount);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Update'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text('Update Count'),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            int decreaseCount = 0;
                                            TextEditingController
                                                _decreaseCountController =
                                                TextEditingController(
                                                    text: decreaseCount
                                                        .toString());
                                            return AlertDialog(
                                              title:
                                                  Text('Decrease Item Count'),
                                              content: TextField(
                                                controller:
                                                    _decreaseCountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Decrease Count',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    int decreaseCount = int.parse(
                                                        _decreaseCountController
                                                            .text);
                                                    decreaseExistingItem(
                                                        items[index]['id'],
                                                        decreaseCount);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Decrease'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text('Decrease Count'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                     /* TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Item Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Item Count',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: addItem,
                        child: Text('Add Item'),
                      ),*/
                    ],
                  ),
                ),
    );
  }
}
