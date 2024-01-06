import 'dart:io';
import 'package:memento/models/category_model.dart';

class ItemModeL {
  ItemModeL(
      {required this.id,
      required this.image,
      required this.title,
      required this.date,
      required this.category});

  final String id;
  final File image;
  final String title;
  final String date;
  final Category category;
}
