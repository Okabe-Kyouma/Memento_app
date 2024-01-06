import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memento/models/category_model.dart';
import 'package:memento/models/item_model.dart';
import 'package:memento/widgets/add_item.dart';
import 'package:memento/widgets/home_list_display.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ItemModeL> resultList = [];
  var _error = 'No';
  var isUndoSuc = 0;
  bool retDone = false;

  @override
  void initState() {
    _reteriveData();
    super.initState();
  }

  void _reteriveData() async {
    setState(() {
      isUndoSuc = 1;
      retDone = true;
    });
    try {
      final uri = Uri.https(
          'memento-1e6f8-default-rtdb.firebaseio.com', 'memento.json');

      final response = await http.get(uri);

      final Map<String, dynamic> listData = json.decode(response.body);

      final List<ItemModeL> loadedItems = [];
      for (final item in listData.entries) {
        loadedItems.add(
          ItemModeL(
            id: item.key,
            image: File(item.value['image']),
            title: item.value['title'],
            date: item.value['date'],
            category: stringToCategory(item.value['category']),
          ),
        );
      }

      setState(() {
        retDone = false;
        isUndoSuc = 0;
        resultList = loadedItems;
      });
    } catch (exe) {
      setState(() {
        resultList = [];
        isUndoSuc = 2;
        retDone = false;
      });
    }
  }

  void _removeItemAndShowSnackBar(index) async {
    ItemModeL item = resultList[index];
    setState(() {
      isUndoSuc = 1;
    });

    try {
      final uri = Uri.https('memento-1e6f8-default-rtdb.firebaseio.com',
          'memento/${item.id}.json');

      final response = await http.delete(
        uri,
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode >= 400) {
        setState(() {
          resultList.remove(item);
          resultList.insert(index, item);
          isUndoSuc = 0;
        });
        _error =
            "There's some problem deleting your memento! Please try again later....";
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _error,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ),
        );
        return;
      } else {
        setState(() {
          resultList.remove(item);
          _error = 'No';
          isUndoSuc = 0;
        });
      }
    } catch (ex) {
      setState(() {
        isUndoSuc = 2;
      });
    }
    setState(() {
      isUndoSuc = 0;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text(
          'Memento Deleted SuccessFully',
          style: TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() async {
                setState(() {
                  isUndoSuc = 1;
                });

                try {
                  final uri = Uri.https(
                      'memento-1e6f8-default-rtdb.firebaseio.com',
                      'memento.json');

                  final response = await http.post(uri,
                      body: json.encode(
                        {
                          'image': item.image
                              .toString()
                              .substring(7, item.image.toString().length - 1),
                          'title': item.title,
                          'date': item.date.toString(),
                          'category': item.category.toString(),
                        },
                      ),
                      headers: {
                        'Content-Type': 'application/json',
                      });

                  if (!mounted) {
                    return;
                  }

                  if (response.statusCode <= 400) {
                    _error = 'Memento restored!';

                    setState(() {
                      resultList.insert(index, item);
                      isUndoSuc = 0;
                    });
                  } else {
                    _error =
                        'Sorry Your memento cant be resotred due to server issue';
                    // ScaffoldMessenger.of(context).clearSnackBars();
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //       _error,
                    //       style: const TextStyle(color: Colors.white),
                    //     ),
                    //     backgroundColor: Colors.black,
                    //   ),
                    // );
                    setState(() {
                      isUndoSuc = 0;
                    });
                  }
                } catch (error) {
                  setState(() {
                    isUndoSuc = 2;
                  });
                }
                setState(() {
                  isUndoSuc = 0;
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _error,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black87,
                  ),
                );
              });
            }),
      ),
    );
  }

  void _addNewMemento() async {
    final newList = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AddItem(),
      ),
    );

    if (newList != null) {
      setState(() {
        resultList.add(newList);
        isUndoSuc = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (resultList.isNotEmpty) {
      content = isUndoSuc == 1
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isUndoSuc == 0
              ? Card(
                  elevation: 200,
                  child: ListView.builder(
                    itemCount: resultList.length,
                    itemBuilder: (ctx, index) => Dismissible(
                      onDismissed: (direction) {
                        _removeItemAndShowSnackBar(index);
                      },
                      key: Key(resultList[index].id),
                      child: HomeListDisplay(
                        item: resultList[index],
                      ),
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
                                setState(() {
                                  isUndoSuc = 0;
                                });
                              },
                              child: const Text('Ok'))
                        ],
                      ),
                    ),
                  ),
                );
    } else if (retDone && resultList.isEmpty && isUndoSuc != 0) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      content = const Center(
        child: Text(
          'Drought of Momentos! Add Some..',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memento'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMemento,
        focusColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
