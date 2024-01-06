import 'package:flutter/material.dart';
import 'package:memento/models/category_model.dart';
import 'package:memento/models/item_model.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeListDisplay extends StatelessWidget {
  const HomeListDisplay({required this.item, super.key});

  final ItemModeL item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FadeInImage(
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: FileImage(
                item.image,
              ),
            ),
          ),
          Positioned(
              right: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: double.infinity,
                height: 80,
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Text(item.date.substring(0, 11)),
                            const Spacer(),
                            Icon(categories[item.category]!.icon),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(categories[item.category]!.reason),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
