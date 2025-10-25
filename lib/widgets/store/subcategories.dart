import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../../const/colors.dart';
import 'item.dart';


class SubCategories extends StatefulWidget {
  final int categoryId;

  SubCategories({required this.categoryId});

  @override
  _SubCategoriesState createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  List<Map<String, dynamic>> subCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubCategories();
  }

  Future<void> fetchSubCategories() async {
    try {
      var response = await http.post(
        Uri.parse(globals.host + '/store/showSubCategories'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"id": widget.categoryId}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('Data received: $data');
        setState(() {
          subCategories = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        print(
            'Failed to load sub-categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sub-categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addSubCategory(int id, String title) async {
    try {
      var response = await http.post(
        Uri.parse(globals.host+'/store/addSubCategory'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"id": id, "title": title}),
      );

      if (response.statusCode == 200) {
        print('SubCategory added successfully');
        fetchSubCategories();
      } else {
        print(
            'Failed to add sub-category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding sub-category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor :AppColors.greenLight,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub-Categories',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add,color: Colors.black,),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController titleController =
                                  TextEditingController();
                              return AlertDialog(
                                title: Text('Add Sub-Category'),
                                content: TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                      hintText: 'Sub-Category Title'),
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
                                      String title =
                                          titleController.text.trim();
                                      if (title.isNotEmpty) {
                                        addSubCategory(
                                            widget.categoryId, title);
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
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: subCategories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          shadowColor: Colors.grey,
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text(
                              subCategories[index]['title'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Items(
                                      subCategoryId: subCategories[index]
                                          ['id']),
                                ),
                              );
                            },
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
