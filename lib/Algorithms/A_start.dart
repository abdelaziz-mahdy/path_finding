// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:path_finding/controllers/controller.dart';

import 'algorithm.dart';

class AStarAlgorithm implements Algorithm {
  AStarAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    final int rows = matrix.length;
    final int columns = matrix[0].length;
    final List<Change> changes = [];

    final List<List<AStarNode>> grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => AStarNode(row, col, matrix[row][col]),
      ),
    );

    AStarNode? startNode;
    AStarNode? endNode;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final BlockState blockState = matrix[row][col];
        if (blockState == BlockState.start) {
          startNode = grid[row][col];
        } else if (blockState == BlockState.end) {
          endNode = grid[row][col];
        }
      }
    }

    if (startNode == null || endNode == null) {
      throw Exception("Start and End nodes need to be set");
    }
    startNode.gScore = 0;
    startNode.calculateFScore(endNode);

    final List<AStarNode> openSet = [startNode];
    final List<AStarNode> closedSet = [];

    while (openSet.isNotEmpty) {
      final currentNode = openSet.reduce((a, b) => a.fScore < b.fScore ? a : b);

      if (currentNode == endNode) {
        final path = constructPath(currentNode);
        return AlgorithmResult(changes, path);
      }

      openSet.remove(currentNode);
      closedSet.add(currentNode);
      changes.add(Change(currentNode.row, currentNode.column, BlockState.visited));

      for (final neighbor in currentNode.getNeighbors(grid, rows, columns)) {
        if (closedSet.contains(neighbor) || neighbor.blockState == BlockState.wall) {
          continue;
        }

        final tentativeGScore = currentNode.gScore + 1;
        if (tentativeGScore < neighbor.gScore) {
          neighbor.cameFrom = currentNode;
          neighbor.gScore = tentativeGScore;
          neighbor.calculateFScore(endNode);
        }

        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
          changes.add(Change(neighbor.row, neighbor.column, BlockState.visited));
        }
      }
    }

    return AlgorithmResult(changes, null);
  }
}

AlgorithmPath constructPath(AStarNode? endNode) {
  if (endNode == null) {
    throw Exception("Did not find end path");
  }
  final List<int> rows = [];
  final List<int> columns = [];
  var currentNode = endNode;

  while (currentNode.cameFrom != null) {
    rows.insert(0, currentNode.row);
    columns.insert(0, currentNode.column);
    currentNode = currentNode.cameFrom!;
  }

  return AlgorithmPath(rows, columns);
}

class AStarNode {
  final int row;
  final int column;
  BlockState blockState;
  AStarNode? cameFrom;
  double gScore;
  int hScore;
  double fScore;

  AStarNode(this.row, this.column, this.blockState)
      : cameFrom = null,
        gScore = double.infinity,
        hScore = 0,
        fScore = 0;

  void calculateFScore(AStarNode endNode) {
    hScore = calculateHScore(endNode);
    fScore = gScore + hScore;
  }

  int calculateHScore(AStarNode endNode) {
    final dx = (column - endNode.column).abs();
    final dy = (row - endNode.row).abs();
    return dx + dy;
  }

  List<AStarNode> getNeighbors(List<List<AStarNode>> grid, int rows, int columns) {
    final List<AStarNode> neighbors = [];
    if (row > 0) neighbors.add(grid[row - 1][column]);
    if (row < rows - 1) neighbors.add(grid[row + 1][column]);
    if (column > 0) neighbors.add(grid[row][column - 1]);
    if (column < columns - 1) neighbors.add(grid[row][column + 1]);
    return neighbors.where((node) => node.blockState != BlockState.wall).toList();
  }

  @override
  bool operator ==(covariant AStarNode other) {
    return other.row == row && other.column == column;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}
