import 'package:flutter/material.dart';
import 'package:path_finding/widgets/block.dart';
import 'package:path_finding/controllers/controller.dart';

class Grid extends StatefulWidget {
  const Grid({
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
    GridController controller = GridController();

    return GestureDetector(
      onTapDown: (details) {
        controller.isMouseClicked = true;
      },
      onTapUp: (details) {
        controller.isMouseClicked = false;
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the width and height based on the parent's constraints
          double gridWidth = constraints.maxWidth;
          double gridHeight = constraints.maxHeight;

          // Calculate the size of each block
          double blockWidth = gridWidth / widget.horizontalBlockCount;
          double blockHeight = gridHeight / widget.verticalBlockCount;

          // Calculate aspect ratio
          double aspectRatio = blockWidth / blockHeight;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.horizontalBlockCount,
              childAspectRatio: aspectRatio,
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
          );
        },
      ),
    );
  }
}
