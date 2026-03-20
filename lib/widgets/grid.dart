import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/models/block_state.dart';

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
                painter: _StreetMapPainter(
                  controller: controller,
                  rows: widget.verticalBlockCount,
                  columns: widget.horizontalBlockCount,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StreetMapPainter extends CustomPainter {
  final GridController controller;
  final int rows;
  final int columns;

  // Road colors
  static const _roadColor = Color(0xFFE8E0D8);
  static const _roadLineColor = Color(0xFFD4CCC4);

  // Building/wall colors
  static const _buildingTop = Color(0xFF5C6B7A);
  static const _buildingSide = Color(0xFF3E4A56);
  static const _buildingShadow = Color(0x40000000);

  // Visited overlay
  static const _visitedColor = Color(0x60B0BEC5);

  // Path (route highlight)
  static const _pathColor = Color(0xFF2196F3);
  static const _pathGlow = Color(0x402196F3);

  // Markers
  static const _startColor = Color(0xFF4CAF50);
  static const _endColor = Color(0xFFE53935);

  _StreetMapPainter({
    required this.controller,
    required this.rows,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / columns;
    final cellH = size.height / rows;
    final matrix = controller.matrix;

    // 1) Draw road base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _roadColor,
    );

    // 2) Draw subtle road grid lines (lane markings)
    final lanePaint = Paint()
      ..color = _roadLineColor
      ..strokeWidth = 0.5;

    for (int i = 0; i <= columns; i++) {
      final x = i * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lanePaint);
    }
    for (int i = 0; i <= rows; i++) {
      final y = i * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lanePaint);
    }

    // 3) Draw visited cells (subtle overlay on roads)
    final visitedPaint = Paint()..color = _visitedColor;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.visited) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
            visitedPaint,
          );
        }
      }
    }

    // 4) Draw path with glow effect (route)
    final pathGlowPaint = Paint()..color = _pathGlow;
    final pathPaint = Paint()..color = _pathColor;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.path) {
          final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
          // Glow (slightly larger)
          canvas.drawRect(rect.inflate(1.5), pathGlowPaint);
          // Path core
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(2)),
            pathPaint,
          );
        }
      }
    }

    // 5) Draw buildings (walls) with 3D effect
    final shadowOffset = cellW * 0.15;
    final shadowPaint = Paint()..color = _buildingShadow;
    final topPaint = Paint()..color = _buildingTop;
    final sidePaint = Paint()..color = _buildingSide;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.wall) {
          final x = c * cellW;
          final y = r * cellH;
          final baseRect = Rect.fromLTWH(x, y, cellW, cellH);

          // Drop shadow (offset down-right)
          canvas.drawRect(
            baseRect.translate(shadowOffset, shadowOffset),
            shadowPaint,
          );

          // Building side (slightly offset to create depth)
          final sidePath = ui.Path()
            ..moveTo(x + cellW, y)
            ..lineTo(x + cellW + shadowOffset * 0.6, y - shadowOffset * 0.4)
            ..lineTo(x + cellW + shadowOffset * 0.6, y + cellH - shadowOffset * 0.4)
            ..lineTo(x + cellW, y + cellH)
            ..close();
          canvas.drawPath(sidePath, sidePaint);

          // Building top face (roof)
          final roofPath = ui.Path()
            ..moveTo(x, y)
            ..lineTo(x + shadowOffset * 0.6, y - shadowOffset * 0.4)
            ..lineTo(x + cellW + shadowOffset * 0.6, y - shadowOffset * 0.4)
            ..lineTo(x + cellW, y)
            ..close();
          canvas.drawPath(roofPath, sidePaint);

          // Building front face
          canvas.drawRect(baseRect, topPaint);

          // Building edge highlight
          final edgePaint = Paint()
            ..color = const Color(0x30FFFFFF)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;
          canvas.drawRect(baseRect.deflate(0.5), edgePaint);
        }
      }
    }

    // 6) Draw start marker (pin)
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.start) {
          _drawMarker(canvas, c * cellW, r * cellH, cellW, cellH, _startColor);
        } else if (matrix[r][c] == BlockState.end) {
          _drawMarker(canvas, c * cellW, r * cellH, cellW, cellH, _endColor);
        }
      }
    }
  }

  void _drawMarker(
      Canvas canvas, double x, double y, double w, double h, Color color) {
    final cx = x + w / 2;
    final cy = y + h / 2;
    final radius = w * 0.4;

    // Shadow
    canvas.drawCircle(
      Offset(cx + 1, cy + 1),
      radius,
      Paint()..color = const Color(0x40000000),
    );

    // Outer circle
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()..color = color,
    );

    // Inner dot
    canvas.drawCircle(
      Offset(cx, cy),
      radius * 0.4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_StreetMapPainter oldDelegate) => true;
}
