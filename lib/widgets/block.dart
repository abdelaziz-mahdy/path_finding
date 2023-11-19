import 'package:flutter/material.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/models/block_state.dart';

class Block extends StatefulWidget {
  const Block({
    Key? key,
    required this.controller,
    required this.onUpdate,
    required this.borderColor,
    required this.row,
    required this.col,
  }) : super(key: key);
  final GridController controller;

  final Function(int row, int col) onUpdate;
  final Color borderColor;
  final int row;
  final int col;

  @override
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {
  void _handlePointerMove(PointerEvent details) {
    widget.onUpdate(widget.row, widget.col);
  }

  @override
  Widget build(BuildContext context) {
    // Assuming getRxBlockState is now returning ValueNotifier<BlockState>
    final ValueNotifier<BlockState> stateNotifier =
        widget.controller.getRxBlockState(widget.row, widget.col);

    return ValueListenableBuilder<BlockState>(
      valueListenable: stateNotifier,
      builder: (context, state, child) {
        return Listener(
          onPointerMove: _handlePointerMove,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.borderColor,
                width: 1.0,
              ),
              color: widget.controller.getFillColorFromState(state),
            ),
            child: const SizedBox(),
          ),
        );
      },
    );
  }
}
