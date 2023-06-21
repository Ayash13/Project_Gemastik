import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;

  CustomBottomSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 248, 235),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(width: 1.5, color: Colors.black),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    height: 5,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: content, // Use the provided content widget
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(210, 224, 188, 188),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                      child: Icon(MdiIcons.closeCircleOutline),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
