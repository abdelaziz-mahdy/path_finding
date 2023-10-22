import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_finding/widgets/block.dart';
import 'package:path_finding/controllers/controller.dart';

class Grid extends StatefulWidget {
  Grid({
    Key? key,
    required this.horizontalBlockCount,
    required this.verticalBlockCount,
    this.borderColor = Colors.grey,
  }) : super(key: key);

  final int horizontalBlockCount;
  final int verticalBlockCount;
  final Color borderColor;

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  @override
  Widget build(BuildContext context) {
    GridController controller = Get.find<GridController>();
    return GestureDetector(
      onTapDown: (details) {
        controller.isMouseClicked = true;
      },
      onTapUp: (details) {
        controller.isMouseClicked = false;
      },
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.horizontalBlockCount,
          childAspectRatio: 1.0,
        ),
        itemCount: widget.horizontalBlockCount * widget.verticalBlockCount,
        itemBuilder: (context, index) {
          final row = index ~/ widget.horizontalBlockCount;
          final col = index % widget.horizontalBlockCount;

          return Block(
            controller: controller,
            borderColor: widget.borderColor,
            row: row,
            col: col,
          );
        },
      ),
    );
  }
}

