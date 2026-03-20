import 'package:flutter/widgets.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/models/block_state.dart';

class Block extends StatelessWidget {
  const Block({
    super.key,
    required this.controller,
    required this.row,
    required this.col,
  });

  final GridController controller;
  final int row;
  final int col;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<BlockState> stateNotifier =
        controller.getRxBlockState(row, col);

    return ValueListenableBuilder<BlockState>(
      valueListenable: stateNotifier,
      builder: (context, state, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          color: controller.getFillColorFromState(state),
        );
      },
    );
  }
}
