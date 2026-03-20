import 'package:flutter/material.dart';
import 'package:path_finding/controllers/controller.dart';

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
  int _lastRow = -1;
  int _lastCol = -1;

  void _handlePointer(PointerEvent details, double cellW, double cellH) {
    final row = (details.localPosition.dy / cellH).floor();
    final col = (details.localPosition.dx / cellW).floor();
    if (row == _lastRow && col == _lastCol) return;
    if (row < 0 || row >= widget.verticalBlockCount) return;
    if (col < 0 || col >= widget.horizontalBlockCount) return;
    controller.updateBlockState(row, col);
    _lastRow = row;
    _lastCol = col;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth / widget.horizontalBlockCount;
        final cellH = constraints.maxHeight / widget.verticalBlockCount;

        return Listener(
          onPointerDown: (d) {
            controller.isMouseClicked = true;
            _handlePointer(d, cellW, cellH);
          },
          onPointerUp: (d) {
            controller.isMouseClicked = false;
            _lastRow = -1;
            _lastCol = -1;
          },
          onPointerMove: (d) => _handlePointer(d, cellW, cellH),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _GridPainter(
                  controller: controller,
                  rows: widget.verticalBlockCount,
                  columns: widget.horizontalBlockCount,
                  gridLineColor: widget.borderColor,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final GridController controller;
  final int rows;
  final int columns;
  final Color gridLineColor;

  _GridPainter({
    required this.controller,
    required this.rows,
    required this.columns,
    required this.gridLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / columns;
    final cellH = size.height / rows;
    final cellPaint = Paint()..style = PaintingStyle.fill;

    // Draw cells
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        cellPaint.color = controller.getFillColorFromState(controller.matrix[r][c]);
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          cellPaint,
        );
      }
    }

    // Draw grid lines
    final linePaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= columns; i++) {
      final x = i * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (int i = 0; i <= rows; i++) {
      final y = i * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => true;
}
