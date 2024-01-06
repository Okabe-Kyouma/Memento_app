import 'package:flutter/material.dart';

enum Category {
  work,
  travel,
  study,
  leisure,
  other,
}

Category stringToCategory(String gotCategory) {
  final data = gotCategory.substring(9, gotCategory.length);

  for (final value in Category.values) {
    if (value.toString() == data) {
      return value;
    } 
  }
   return Category.other;
}

const categories = {
  Category.work: CategoryModel(icon: Icons.work, reason: 'For Work'),
  Category.travel: CategoryModel(icon: Icons.flight_takeoff, reason: 'Travel'),
  Category.study: CategoryModel(icon: Icons.book, reason: 'Studies'),
  Category.leisure: CategoryModel(icon: Icons.local_activity, reason: 'Fun'),
  Category.other: CategoryModel(icon: Icons.more_horiz, reason: 'Other'),
};

class CategoryModel {
  const CategoryModel({required this.icon, required this.reason});

  final IconData icon;
  final String reason;
}
