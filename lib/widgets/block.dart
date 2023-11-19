import 'package:flutter/widgets.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/models/block_state.dart';

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
    final ValueNotifier<BlockState> stateNotifier = widget.controller.getRxBlockState(widget.row, widget.col);

    return ValueListenableBuilder<BlockState>(
      valueListenable: stateNotifier,
      builder: (context, state, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            color: widget.controller.getFillColorFromState(state),
          ),
          child: const SizedBox(),
        );
      },
    );
  }
}
