import 'package:flutter/material.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/block.dart';
// Import your GridController and Block classes here

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
  final GridController controller =
      GridController(); // Assuming GridController is defined elsewhere
  int justUpdatedRow = -1;
  int justUpdatedCol = -1;
  void _handlePointerMove(
      PointerEvent details, double blockWidth, double blockHeight) {
    
    int row = (details.localPosition.dy / blockHeight).floor();
    int col = (details.localPosition.dx / blockWidth).floor();
    if (row == justUpdatedRow && col == justUpdatedCol) {
      return;
    }
    controller.updateBlockState(row, col);
    justUpdatedRow = row;
    justUpdatedCol = col;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double gridWidth = constraints.maxWidth;
        double gridHeight = constraints.maxHeight;
        double blockWidth = gridWidth / widget.horizontalBlockCount;
        double blockHeight = gridHeight / widget.verticalBlockCount;
        double aspectRatio = blockWidth / blockHeight;

        return Listener(
            onPointerDown: (details) {
              controller.isMouseClicked = true;
              print(" mouse clicked ");
            },
            onPointerUp: (details) {
              controller.isMouseClicked = false;
              print(" mouse released ");
            },
            onPointerMove: (details) {
              _handlePointerMove(details, blockWidth, blockHeight);
            },
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.horizontalBlockCount,
                childAspectRatio: aspectRatio,
              ),
              itemCount:
                  widget.horizontalBlockCount * widget.verticalBlockCount,
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
            ));
      },
    );
  }
}
