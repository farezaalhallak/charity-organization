import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:untitled/widgets/store/subcategories.dart';
import '../../const/colors.dart';
// Import the sub-categories screen

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      var response =
          await http.get(Uri.parse(globals.host + '/store/showCategories'), headers: {
            'authorization': globals.token,
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> addCategory(String title) async {
    try {
      var response = await http.post(
        Uri.parse(globals.host + '/store/addCategory'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'title': title}),
      );

      if (response.statusCode == 200) {
        print('Category added successfully');
        // Assuming the server returns the updated list of categories,
        // we fetch categories again to refresh the UI
        fetchCategories();
      } else {
        throw Exception('Failed to add category');
      }
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   backgroundColor: AppColors.greenLight,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text(
                      'Categories',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add,color: Colors.black,),
                    onPressed: () {
                      // Show dialog to add category
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController titleController =
                              TextEditingController();
                          return AlertDialog(
                            title: Text('Add Category'),
                            content: TextField(
                              controller: titleController,
                              decoration:
                                  InputDecoration(hintText: 'Category Title'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String title = titleController.text.trim();
                                  if (title.isNotEmpty) {
                                    addCategory(title);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to SubCategories screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubCategories(
                              categoryId: categories[index]['id']),
                        ),
                      );
                    },
                    child: Card(
                      shadowColor: Colors.grey,
                      elevation: 5,
                      margin: EdgeInsets.symmetric(
                          vertical:
                              10), // Add some vertical margin between cards
                      child: ListTile(
                        title: Text(
                          categories[index]['title'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                      ),
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
