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

  // Road path colors
  static const _pathAsphalt = Color(0xFF555555);
  static const _pathEdge = Color(0xFF3A3A3A);
  static const _pathCenterLine = Color(0xFFFFD54F);
  static const _pathGlow = Color(0x302196F3);

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

    // 4) Draw path as a connected road
    _drawPathRoad(canvas, matrix, cellW, cellH);

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

  void _drawPathRoad(
      Canvas canvas, List<List<BlockState>> matrix, double cellW, double cellH) {
    // Collect ordered path cells
    final pathCells = <Offset>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.path) {
          pathCells.add(Offset(c * cellW + cellW / 2, r * cellH + cellH / 2));
        }
      }
    }
    if (pathCells.isEmpty) return;

    // Sort path cells into connected order using adjacency
    final ordered = _orderPathCells(matrix, cellW, cellH);
    if (ordered.isEmpty) return;

    final roadWidth = cellW * 0.75;

    // Glow under the road
    final glowPaint = Paint()
      ..color = _pathGlow
      ..strokeWidth = roadWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Road edge (dark border)
    final edgePaint = Paint()
      ..color = _pathEdge
      ..strokeWidth = roadWidth + 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Asphalt surface
    final asphaltPaint = Paint()
      ..color = _pathAsphalt
      ..strokeWidth = roadWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Center dashed line
    final centerLinePaint = Paint()
      ..color = _pathCenterLine
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Build the road path
    final roadPath = ui.Path();
    roadPath.moveTo(ordered[0].dx, ordered[0].dy);
    for (int i = 1; i < ordered.length; i++) {
      roadPath.lineTo(ordered[i].dx, ordered[i].dy);
    }

    // Draw layers: glow → edge → asphalt
    canvas.drawPath(roadPath, glowPaint);
    canvas.drawPath(roadPath, edgePaint);
    canvas.drawPath(roadPath, asphaltPaint);

    // Draw dashed center line
    _drawDashedLine(canvas, ordered, centerLinePaint, cellW * 0.4, cellW * 0.3);
  }

  /// Orders path cells by walking adjacency from start to end.
  List<Offset> _orderPathCells(
      List<List<BlockState>> matrix, double cellW, double cellH) {
    // Find all path cells and start/end
    int? startR, startC, endR, endC;
    final isPath = List.generate(
        rows, (r) => List.generate(columns, (c) => false));

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.path) {
          isPath[r][c] = true;
        } else if (matrix[r][c] == BlockState.start) {
          startR = r;
          startC = c;
        } else if (matrix[r][c] == BlockState.end) {
          endR = r;
          endC = c;
        }
      }
    }

    // Find path cell adjacent to start
    int? firstR, firstC;
    if (startR != null && startC != null) {
      for (final (dr, dc) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nr = startR + dr;
        final nc = startC + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < columns && isPath[nr][nc]) {
          firstR = nr;
          firstC = nc;
          break;
        }
      }
    }

    if (firstR == null || firstC == null) {
      // Fallback: just return path cells in scan order
      final result = <Offset>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < columns; c++) {
          if (isPath[r][c]) {
            result.add(Offset(c * cellW + cellW / 2, r * cellH + cellH / 2));
          }
        }
      }
      return result;
    }

    // Walk from start marker through path to end
    final ordered = <Offset>[
      Offset(startC! * cellW + cellW / 2, startR! * cellH + cellH / 2),
    ];

    final visited = List.generate(
        rows, (r) => List.generate(columns, (c) => false));
    var cr = firstR;
    var cc = firstC;

    while (true) {
      visited[cr][cc] = true;
      ordered.add(Offset(cc * cellW + cellW / 2, cr * cellH + cellH / 2));

      // Check if adjacent to end
      if (endR != null && endC != null) {
        if ((cr - endR).abs() + (cc - endC).abs() == 1) {
          ordered.add(
              Offset(endC * cellW + cellW / 2, endR * cellH + cellH / 2));
          break;
        }
      }

      // Find next unvisited path neighbor
      bool found = false;
      for (final (dr, dc) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nr = cr + dr;
        final nc = cc + dc;
        if (nr >= 0 &&
            nr < rows &&
            nc >= 0 &&
            nc < columns &&
            isPath[nr][nc] &&
            !visited[nr][nc]) {
          cr = nr;
          cc = nc;
          found = true;
          break;
        }
      }
      if (!found) break;
    }

    return ordered;
  }

  void _drawDashedLine(Canvas canvas, List<Offset> points, Paint paint,
      double dashLen, double gapLen) {
    double remaining = 0;
    bool drawing = true;

    for (int i = 1; i < points.length; i++) {
      var from = points[i - 1];
      final to = points[i];
      final dx = to.dx - from.dx;
      final dy = to.dy - from.dy;
      final segLen = (dx * dx + dy * dy).clamp(0.001, double.infinity);
      final sqrtDist = _sqrt(segLen);
      final ux = dx / sqrtDist;
      final uy = dy / sqrtDist;

      var traveled = 0.0;
      while (traveled < sqrtDist) {
        final target = drawing ? dashLen : gapLen;
        final available = sqrtDist - traveled;
        final step = (target - remaining).clamp(0.0, available);

        if (drawing) {
          final end = Offset(from.dx + ux * step, from.dy + uy * step);
          canvas.drawLine(from, end, paint);
          from = end;
        } else {
          from = Offset(from.dx + ux * step, from.dy + uy * step);
        }

        traveled += step;
        remaining += step;

        if (remaining >= target) {
          remaining = 0;
          drawing = !drawing;
        }
      }
    }
  }

  static double _sqrt(double v) {
    // Newton's method approximation for performance
    double x = v;
    double y = (x + 1) / 2;
    while ((y - x).abs() > 0.001) {
      x = y;
      y = (x + v / x) / 2;
    }
    return y;
  }

  @override
  bool shouldRepaint(_StreetMapPainter oldDelegate) => true;
}
