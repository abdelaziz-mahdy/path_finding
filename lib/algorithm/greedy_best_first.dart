import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/node/path_node.dart';
import 'package:path_finding/models/models.dart';

class GreedyBestFirstAlgorithm implements Algorithm {
  GreedyBestFirstAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    final rows = matrix.length;
    final columns = matrix[0].length;
    final changes = <Change>[];

    final grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => GreedyNode(row, col, matrix[row][col]),
      ),
    );

    GreedyNode? startNode;
    GreedyNode? endNode;
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

    startNode.hScore = startNode.calculateHScore(endNode);

    final openSet = <GreedyNode>[startNode];
    final closedSet = <GreedyNode>{};

    while (openSet.isNotEmpty) {
      final currentNode =
          openSet.reduce((a, b) => a.hScore < b.hScore ? a : b);

      if (currentNode == endNode) {
        final path = constructPath(currentNode);
        return AlgorithmResult(changes, path);
      }

      openSet.remove(currentNode);
      closedSet.add(currentNode);
      changes.add(
          Change(currentNode.row, currentNode.column, BlockState.visited));

      for (final neighbor in currentNode.getNeighbors(grid, rows, columns)) {
        if (closedSet.contains(neighbor) ||
            neighbor.blockState == BlockState.wall) {
          continue;
        }

        if (!openSet.contains(neighbor)) {
          neighbor.cameFrom = currentNode;
          neighbor.hScore = neighbor.calculateHScore(endNode);
          openSet.add(neighbor);
          changes.add(
              Change(neighbor.row, neighbor.column, BlockState.visited));
        }
      }
    }

    return AlgorithmResult(changes, null);
  }

  @override
  String name = "Greedy Best-First";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Algorithm && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class GreedyNode extends PathNode {
  int hScore;
  BlockState blockState;

  GreedyNode(int row, int column, this.blockState)
      : hScore = 0,
        super(row, column);

  int calculateHScore(GreedyNode endNode) {
    final dx = (column - endNode.column).abs();
    final dy = (row - endNode.row).abs();
    return dx + dy;
  }

  List<GreedyNode> getNeighbors(
      List<List<GreedyNode>> grid, int rows, int columns) {
    final neighbors = <GreedyNode>[];
    if (row > 0) neighbors.add(grid[row - 1][column]);
    if (row < rows - 1) neighbors.add(grid[row + 1][column]);
    if (column > 0) neighbors.add(grid[row][column - 1]);
    if (column < columns - 1) neighbors.add(grid[row][column + 1]);

    return neighbors
        .where((node) => node.blockState != BlockState.wall)
        .toList();
  }
}
