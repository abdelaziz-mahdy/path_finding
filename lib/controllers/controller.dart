import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_finding/models/models.dart';

class GridController {
  static final GridController _instance = GridController._internal();

  factory GridController() {
    return _instance;
  }

  GridController._internal() {
    _onInit();
  }

  final ValueNotifier<bool> mouseClicked = ValueNotifier(false);
  final ValueNotifier<bool> findingPath = ValueNotifier(false);

  late List<List<ValueNotifier<BlockState>>> matrix;
  late int rows;
  late int columns;
  CursorType cursorType = CursorType.wall;

  /// Incremented on every cancel/reset to abort running animations.
  int _animationGeneration = 0;

  void _onInit() {
    createMatrix(25, 25);
    setRandomStartAndEndBlocks();
  }

  Color fillColor(int row, int column) {
    final state = matrix[row][column].value;
    return getFillColorFromState(state);
  }

  List<List<BlockState>> getMatrixValues() {
    final List<List<BlockState>> matrixValues = [];
    for (final row in matrix) {
      final List<BlockState> rowValues = [];
      for (final blockState in row) {
        rowValues.add(blockState.value);
      }
      matrixValues.add(rowValues);
    }
    return matrixValues;
  }

  Color getFillColorFromState(BlockState state) {
    switch (state) {
      case BlockState.none:
        return const Color(0xFFFAFAFA);
      case BlockState.wall:
        return const Color(0xFF37474F);
      case BlockState.visited:
        return const Color(0xFF90A4AE);
      case BlockState.path:
        return const Color(0xFF42A5F5);
      case BlockState.start:
        return const Color(0xFF4CAF50);
      case BlockState.end:
        return const Color(0xFFE53935);
    }
  }

  set isMouseClicked(bool value) {
    mouseClicked.value = value;
  }

  bool get isMouseClicked {
    return mouseClicked.value;
  }

  bool get isChangingWallStateAllowed {
    return mouseClicked.value && !findingPath.value;
  }

  void updateBlockState(int row, int column) {
    if (rows < 0 || columns < 0 || row >= rows || column >= columns) {
      return;
    }
    if (isChangingWallStateAllowed) {
      final currentBlockState = matrix[row][column].value;
      BlockState newBlockState = currentBlockState;

      switch (cursorType) {
        case CursorType.start:
          newBlockState = BlockState.start;
          resetStartPoint();
          break;
        case CursorType.end:
          newBlockState = BlockState.end;
          resetEndPoint();
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

      matrix[row][column].value = newBlockState;
    }
  }

  void setStartPoint(int row, int column) {
    if (cursorType == CursorType.start) {
      resetStartPoint();
      matrix[row][column].value = BlockState.start;
    }
  }

  void setEndPoint(int row, int column) {
    if (cursorType == CursorType.end) {
      resetEndPoint();
      matrix[row][column].value = BlockState.end;
    }
  }

  void resetStartPoint() {
    for (final row in matrix) {
      for (final blockState in row) {
        if (blockState.value == BlockState.start) {
          blockState.value = BlockState.none;
          return;
        }
      }
    }
  }

  void resetEndPoint() {
    for (final row in matrix) {
      for (final blockState in row) {
        if (blockState.value == BlockState.end) {
          blockState.value = BlockState.none;
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
      (_) => List<ValueNotifier<BlockState>>.generate(
        columns,
        (_) => ValueNotifier<BlockState>(BlockState.none),
      ),
    );
  }

  void resetMatrix() {
    // Cancel any running animation
    _animationGeneration++;
    findingPath.value = false;

    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col].value == BlockState.visited ||
            matrix[row][col].value == BlockState.path) {
          matrix[row][col].value = BlockState.none;
        }
      }
    }
  }

  void setRandomStartAndEndBlocks() {
    final Random random = Random();

    final int startRow = random.nextInt(rows);
    final int endRow = random.nextInt(rows);

    final int startCol = random.nextInt(columns ~/ 2);
    final int endCol = random.nextInt(columns ~/ 2) + columns ~/ 2;

    matrix[startRow][startCol].value = BlockState.start;
    matrix[endRow][endCol].value = BlockState.end;
  }

  ValueNotifier<BlockState> getRxBlockState(int row, int column) {
    return matrix[row][column];
  }

  Future<void> applyAlgorithmResult(AlgorithmResult result,
      {Duration timeBetweenChanges = const Duration(milliseconds: 20)}) async {
    // Cancel any previous animation and capture this generation
    _animationGeneration++;
    final generation = _animationGeneration;

    findingPath.value = true;

    final List<Change> changes = result.changes;
    final AlgorithmPath? path = result.path;
    resetMatrixKeepGeneration();

    for (final change in changes) {
      if (_animationGeneration != generation) return;

      final int row = change.row;
      final int column = change.column;
      final BlockState newState = change.newState;

      if (matrix[row][column].value == BlockState.start ||
          matrix[row][column].value == BlockState.end) {
        continue;
      }

      matrix[row][column].value = newState;
      await Future.delayed(timeBetweenChanges);
    }

    if (_animationGeneration != generation) return;

    if (path != null) {
      await _updateEndPath(path, generation);
    }

    if (_animationGeneration == generation) {
      findingPath.value = false;
    }
  }

  /// Clears visited/path cells without bumping the generation counter.
  void resetMatrixKeepGeneration() {
    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col].value == BlockState.visited ||
            matrix[row][col].value == BlockState.path) {
          matrix[row][col].value = BlockState.none;
        }
      }
    }
  }

  Future<void> _updateEndPath(AlgorithmPath path, int generation) async {
    for (int i = 0; i < path.rows.length; i++) {
      if (_animationGeneration != generation) return;

      final row = path.rows[i];
      final col = path.columns[i];

      if (matrix[row][col].value == BlockState.start ||
          matrix[row][col].value == BlockState.end) {
        continue;
      }

      matrix[row][col].value = BlockState.path;
      await Future.delayed(const Duration(milliseconds: 2));
    }
  }
}
