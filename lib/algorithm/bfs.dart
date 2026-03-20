import 'dart:collection';

import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/node/path_node.dart';
import 'package:path_finding/models/models.dart';

class BfsAlgorithm implements Algorithm {
  BfsAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    final rows = matrix.length;
    final columns = matrix[0].length;
    final changes = <Change>[];

    final grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => BfsNode(row, col, matrix[row][col]),
      ),
    );

    BfsNode? startNode;
    BfsNode? endNode;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        if (matrix[row][col] == BlockState.start) {
          startNode = grid[row][col];
        } else if (matrix[row][col] == BlockState.end) {
          endNode = grid[row][col];
        }
      }
    }

    if (startNode == null || endNode == null) {
      throw Exception("Start and End nodes need to be set");
    }

    final queue = Queue<BfsNode>();
    startNode.visited = true;
    queue.add(startNode);

    while (queue.isNotEmpty) {
      final currentNode = queue.removeFirst();

      if (currentNode == endNode) {
        final path = constructPath(currentNode);
        return AlgorithmResult(changes, path);
      }

      changes.add(
          Change(currentNode.row, currentNode.column, BlockState.visited));

      for (final neighbor in currentNode.getNeighbors(grid, rows, columns)) {
        if (!neighbor.visited && neighbor.blockState != BlockState.wall) {
          neighbor.visited = true;
          neighbor.cameFrom = currentNode;
          queue.add(neighbor);
          changes.add(
              Change(neighbor.row, neighbor.column, BlockState.visited));
        }
      }
    }

    return AlgorithmResult(changes, null);
  }

  @override
  String name = "BFS";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Algorithm && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class BfsNode extends PathNode {
  bool visited;
  BlockState blockState;

  BfsNode(int row, int column, this.blockState)
      : visited = false,
        super(row, column);

  List<BfsNode> getNeighbors(
      List<List<BfsNode>> grid, int rows, int columns) {
    final neighbors = <BfsNode>[];
    if (row > 0) neighbors.add(grid[row - 1][column]);
    if (row < rows - 1) neighbors.add(grid[row + 1][column]);
    if (column > 0) neighbors.add(grid[row][column - 1]);
    if (column < columns - 1) neighbors.add(grid[row][column + 1]);

    return neighbors
        .where((node) => node.blockState != BlockState.wall)
        .toList();
  }
}
