import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_finding/controller.dart';

class Grid extends StatelessWidget {
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
          crossAxisCount: horizontalBlockCount,
          childAspectRatio: 1.0,
        ),
        itemCount: horizontalBlockCount * verticalBlockCount,
        itemBuilder: (context, index) {
          final row = index ~/ horizontalBlockCount;
          final col = index % horizontalBlockCount;

          return Block(
            controller: controller,
            borderColor: borderColor,
            row: row,
            col: col,
          );
        },
      ),
    );
  }
}

class Block extends StatelessWidget {
  const Block({
    Key? key,
    required this.controller,
    required this.borderColor,
    required this.row,
    required this.col,
  }) : super(key: key);

  final GridController controller;
  final Color borderColor;
  final int row;
  final int col;

  @override
  Widget build(BuildContext context) {
    final Rx<BlockState> state = controller.getRxBlockState(row, col);

    return Obx(() => MouseRegion(
          onEnter: (event) {
            controller.updateBlockState(row, col);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
              color: controller.getFillColorFromState(state.value),
            ),
            child: SizedBox(),
          ),
        ));
  }
}
