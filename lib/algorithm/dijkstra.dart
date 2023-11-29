import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/node/path_node.dart';
import 'package:path_finding/models/models.dart';

class DijkstraAlgorithm implements Algorithm {
  DijkstraAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    final rows = matrix.length;
    final columns = matrix[0].length;
    final changes = <Change>[];

    final grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => DijkstraNode(row, col, matrix[row][col]),
      ),
    );

    DijkstraNode? startNode;
    DijkstraNode? endNode;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final blockState = matrix[row][col];
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
    startNode.distance = 0;

    final openSet = [startNode];
    final closedSet = <DijkstraNode>[];

    while (openSet.isNotEmpty) {
      final currentNode =
          openSet.reduce((a, b) => a.distance < b.distance ? a : b);

      if (currentNode == endNode) {
        final path = constructPath(currentNode);
        return AlgorithmResult(changes, path);
      }

      openSet.remove(currentNode);
      closedSet.add(currentNode);
      changes
          .add(Change(currentNode.row, currentNode.column, BlockState.visited));

      for (final neighbor in currentNode.getNeighbors(grid, rows, columns)) {
        if (closedSet.contains(neighbor) ||
            neighbor.blockState == BlockState.wall) {
          continue;
        }

        final newDistance = currentNode.distance + 1;
        if (newDistance < neighbor.distance) {
          neighbor.cameFrom = currentNode;
          neighbor.distance = newDistance;
        }

        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
          changes
              .add(Change(neighbor.row, neighbor.column, BlockState.visited));
        }
      }
    }

    return AlgorithmResult(changes, null);
  }

  @override
  String name = "Dijkstra";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Algorithm && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class DijkstraNode extends PathNode {
  int distance;
  BlockState blockState;

  DijkstraNode(int row, int column, this.blockState)
      : distance = 2147483647, // Maximum value for 32-bit integer
        super(row, column);

  List<DijkstraNode> getNeighbors(
      List<List<DijkstraNode>> grid, int rows, int columns) {
    final neighbors = <DijkstraNode>[];
    if (row > 0) neighbors.add(grid[row - 1][column]);
    if (row < rows - 1) neighbors.add(grid[row + 1][column]);
    if (column > 0) neighbors.add(grid[row][column - 1]);
    if (column < columns - 1) neighbors.add(grid[row][column + 1]);

    // Filter out wall nodes if necessary
    return neighbors
        .where((node) => node.blockState != BlockState.wall)
        .toList();
  }
}
