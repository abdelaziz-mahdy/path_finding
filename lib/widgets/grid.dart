import 'package:flutter/material.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/block.dart';

class Grid extends StatefulWidget {
  const Grid({
    super.key,
    required this.horizontalBlockCount,
    required this.verticalBlockCount,
    this.borderColor = Colors.grey,
  });

  final int horizontalBlockCount;
  final int verticalBlockCount;
  final Color borderColor;

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  final GridController controller = GridController();
  int justUpdatedRow = -1;
  int justUpdatedCol = -1;

  void _handlePointerEvent(PointerEvent details, double blockWidth, double blockHeight) {
    int row = (details.localPosition.dy / blockHeight).floor();
    int col = (details.localPosition.dx / blockWidth).floor();
    if (row == justUpdatedRow && col == justUpdatedCol) return;
    if (row < 0 || row >= widget.verticalBlockCount) return;
    if (col < 0 || col >= widget.horizontalBlockCount) return;
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
            _handlePointerEvent(details, blockWidth, blockHeight);
          },
          onPointerUp: (details) {
            controller.isMouseClicked = false;
            justUpdatedRow = -1;
            justUpdatedCol = -1;
          },
          onPointerMove: (details) {
            _handlePointerEvent(details, blockWidth, blockHeight);
          },
          child: Stack(
            children: [
              GridView.builder(
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
                    row: row,
                    col: col,
                  );
                },
              ),
              // Grid lines overlay
              IgnorePointer(
                child: CustomPaint(
                  size: Size(gridWidth, gridHeight),
                  painter: _GridLinesPainter(
                    rows: widget.verticalBlockCount,
                    columns: widget.horizontalBlockCount,
                    color: widget.borderColor,
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

class _GridLinesPainter extends CustomPainter {
  final int rows;
  final int columns;
  final Color color;

  _GridLinesPainter({
    required this.rows,
    required this.columns,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // Draw vertical lines
    for (int i = 0; i <= columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinesPainter oldDelegate) =>
      rows != oldDelegate.rows ||
      columns != oldDelegate.columns ||
      color != oldDelegate.color;
}
