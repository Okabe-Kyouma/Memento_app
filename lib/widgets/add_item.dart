import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memento/models/category_model.dart';
import 'package:memento/models/item_model.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _key = GlobalKey<FormState>();
  File? _image;
  final List<ItemModeL> myList = [];
  var isAddingItemInProcess = 2;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    } else {
      setState(() {
        _image = null;
      });
    }
  }

  DateTime? _selectedDate;
  String? _selectedTitle;
  Category? _selectedCategory;

  void pickDate() async {
    final firstDate = DateTime(
        DateTime.now().day, DateTime.now().month, DateTime.now().year - 1);
    final lastDate = DateTime.now();
    final val = await showDatePicker(
        context: context, firstDate: firstDate, lastDate: lastDate);

    setState(() {
      if (val == null) {
        _selectedDate = null;
      } else {
        _selectedDate = val;
      }
    });
  }

  void resetFormData() {
    setState(() {
      _key.currentState!.reset();
      _selectedDate = null;
      _image = null;
    });
  }

  void addNewMemento() async {
    if (!_key.currentState!.validate()) {
      return;
    }

    if (_image == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Photo Not Selected'),
          content: const Text(
              'Please make sure you have selected a photo before adding the memento!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Date Not selected'),
          content: const Text(
              'Please make sure you have selected the date before adding the memento!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }

    _key.currentState!.save();
    setState(() {
      isAddingItemInProcess = 1;
    });

    try {
      final uri = Uri.https(
          'memento-1e6f8-default-rtdb.firebaseio.com', 'memento.json');

      final response = await http.post(uri,
          body: json.encode(
            {
              'image':
                  _image.toString().substring(7, _image.toString().length - 1),
              'title': _selectedTitle,
              'date': _selectedDate.toString(),
              'category': _selectedCategory.toString(),
            },
          ),
          headers: {
            'Content-Type': 'application/json',
          });

      if (response.statusCode >= 400) {
        setState(() {
          isAddingItemInProcess = 0;
        });
        return;
      }

      final Map<String, dynamic> res = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      setState(() {
        isAddingItemInProcess = 2;
      });

      Navigator.of(context).pop(
        ItemModeL(
            id: res['name'],
            image: _image!,
            title: _selectedTitle!,
            date: _selectedDate.toString(),
            category: _selectedCategory!),
      );
    } catch (error) {
      setState(() {
        isAddingItemInProcess = 0;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Memento'),
        ),
        body: isAddingItemInProcess == 1
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isAddingItemInProcess == 2
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _key,
                      child: Column(
                        children: [
                          TextFormField(
                            maxLength: 50,
                            decoration: const InputDecoration(
                              label: Text('Title'),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length <= 1 ||
                                  value.length > 50) {
                                return 'Please make sure the correct title is entered!';
                              }
                              _selectedTitle = value;
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: pickDate,
                                  icon: const Icon(Icons.calendar_month)),
                              const SizedBox(
                                width: 10,
                              ),
                              _selectedDate == null
                                  ? const Text('Select Date')
                                  : Text(_selectedDate
                                      .toString()
                                      .substring(0, 11)),
                              const SizedBox(
                                width: 70,
                              ),
                              Expanded(
                                child: DropdownButtonFormField(
                                  hint: const Text(
                                    'Select Category',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  items: [
                                    for (final item in categories.entries)
                                      DropdownMenuItem(
                                        value: item.key,
                                        child: Row(
                                          children: [
                                            Icon(item.value.icon),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(item.value.reason),
                                          ],
                                        ),
                                      ),
                                  ],
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a category';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _selectedCategory = value;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed: _image == null ? getImage : null,
                                style: OutlinedButton.styleFrom(
                                  shape: const BeveledRectangleBorder(),
                                ),
                                child: _image == null
                                    ? const Row(children: [
                                        Icon(Icons.image),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Pick Image'),
                                      ])
                                    : const Row(children: [
                                        Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Got Image'),
                                      ]),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              OutlinedButton(
                                onPressed: resetFormData,
                                style: OutlinedButton.styleFrom(
                                  shape: const BeveledRectangleBorder(),
                                ),
                                child: const Text('Reset'),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              OutlinedButton(
                                onPressed: addNewMemento,
                                style: OutlinedButton.styleFrom(
                                  shape: const BeveledRectangleBorder(),
                                ),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: SizedBox(
                      height: 300,
                      child: Dialog(
                        child: AlertDialog(
                          content: const Text(
                              'Theres Some issue with Server!! Please Try again later..'),
                          title: const Text('Server Down'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok'))
                          ],
                        ),
                      ),
                    ),
                  ),
                  );
  }
}
