import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/grid.dart';

class Block extends StatefulWidget {
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
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {
  @override
  Widget build(BuildContext context) {
    final Rx<BlockState> state =
        widget.controller.getRxBlockState(widget.row, widget.col);

    return Obx(() => MouseRegion(
          onEnter: (event) {
            widget.controller.updateBlockState(widget.row, widget.col);
          },
          child: AnimatedContainer(
            // key: Key(state.value.name),
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.borderColor,
                width: 1.0,
              ),
              color: widget.controller.getFillColorFromState(state.value),
            ),

            child: SizedBox(),
          ),
        ));
  }
}
