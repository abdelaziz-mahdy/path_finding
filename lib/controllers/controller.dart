import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_finding/models/models.dart';

class GridController extends ChangeNotifier {
  static final GridController _instance = GridController._internal();

  factory GridController() {
    return _instance;
  }

  GridController._internal() {
    _onInit();
  }

  bool _findingPath = false;

  late List<List<BlockState>> matrix;
  late int rows;
  late int columns;
  CursorType cursorType = CursorType.wall;

  int _animationGeneration = 0;

  /// Current animation speed — read live during animation so slider changes
  /// take effect immediately.
  Duration timeBetweenChanges = const Duration(milliseconds: 20);

  bool get findingPath => _findingPath;

  void _onInit() {
    createMatrix(50, 50);
    setRandomStartAndEndBlocks();
  }

  List<List<BlockState>> getMatrixValues() {
    return List.generate(
      rows,
      (r) => List.generate(columns, (c) => matrix[r][c]),
    );
  }

  static const Map<BlockState, Color> stateColors = {
    BlockState.none: Color(0xFFFAFAFA),
    BlockState.wall: Color(0xFF37474F),
    BlockState.visited: Color(0xFF90A4AE),
    BlockState.path: Color(0xFF42A5F5),
    BlockState.start: Color(0xFF4CAF50),
    BlockState.end: Color(0xFFE53935),
  };

  Color getFillColorFromState(BlockState state) {
    return stateColors[state] ?? const Color(0xFFFAFAFA);
  }

  bool isMouseClicked = false;

  bool get isChangingWallStateAllowed {
    return isMouseClicked && !_findingPath;
  }

  void updateBlockState(int row, int column) {
    if (row < 0 || column < 0 || row >= rows || column >= columns) {
      return;
    }
    if (!isChangingWallStateAllowed) return;

    final currentBlockState = matrix[row][column];
    BlockState newBlockState = currentBlockState;

    switch (cursorType) {
      case CursorType.start:
        newBlockState = BlockState.start;
        _resetPoint(BlockState.start);
        break;
      case CursorType.end:
        newBlockState = BlockState.end;
        _resetPoint(BlockState.end);
        break;
      case CursorType.wall:
        newBlockState = BlockState.wall;
      case CursorType.eraser:
        if (currentBlockState == BlockState.wall) {
          newBlockState = BlockState.none;
        }
      case CursorType.none:
        break;
    }

    if (matrix[row][column] != newBlockState) {
      matrix[row][column] = newBlockState;
      notifyListeners();
    }
  }

  void _resetPoint(BlockState target) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == target) {
          matrix[r][c] = BlockState.none;
          return;
        }
      }
    }
  }

  void createMatrix(int rows, int columns) {
    this.rows = rows;
    this.columns = columns;
    matrix = List.generate(
      rows,
      (_) => List.generate(columns, (_) => BlockState.none),
    );
  }

  void resetMatrix() {
    _animationGeneration++;
    _findingPath = false;

    bool changed = false;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.visited ||
            matrix[r][c] == BlockState.path) {
          matrix[r][c] = BlockState.none;
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  void setRandomStartAndEndBlocks() {
    final Random random = Random();

    final int startRow = random.nextInt(rows);
    final int endRow = random.nextInt(rows);
    final int startCol = random.nextInt(columns ~/ 2);
    final int endCol = random.nextInt(columns ~/ 2) + columns ~/ 2;

    matrix[startRow][startCol] = BlockState.start;
    matrix[endRow][endCol] = BlockState.end;
    notifyListeners();
  }

  Future<void> applyAlgorithmResult(AlgorithmResult result) async {
    _animationGeneration++;
    final generation = _animationGeneration;
    _findingPath = true;

    // Clear visited/path first
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (matrix[r][c] == BlockState.visited ||
            matrix[r][c] == BlockState.path) {
          matrix[r][c] = BlockState.none;
        }
      }
    }
    notifyListeners();

    final changes = result.changes;
    final path = result.path;

    // Batch changes: accumulate a few before notifying
    int batchCount = 0;
    const batchSize = 3;

    for (final change in changes) {
      if (_animationGeneration != generation) return;

      if (matrix[change.row][change.column] == BlockState.start ||
          matrix[change.row][change.column] == BlockState.end) {
        continue;
      }

      matrix[change.row][change.column] = change.newState;
      batchCount++;

      if (batchCount >= batchSize) {
        batchCount = 0;
        notifyListeners();
        await Future.delayed(timeBetweenChanges);
      }
    }

    // Flush remaining
    if (batchCount > 0 && _animationGeneration == generation) {
      notifyListeners();
    }

    if (_animationGeneration != generation) return;

    // Draw final path
    if (path != null) {
      for (int i = 0; i < path.rows.length; i++) {
        if (_animationGeneration != generation) return;

        final r = path.rows[i];
        final c = path.columns[i];
        if (matrix[r][c] == BlockState.start ||
            matrix[r][c] == BlockState.end) {
          continue;
        }

        matrix[r][c] = BlockState.path;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 2));
      }
    }

    if (_animationGeneration == generation) {
      _findingPath = false;
    }
  }
}
