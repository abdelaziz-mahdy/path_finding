import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/node/path_node.dart';
import 'package:path_finding/models/models.dart';

class DfsAlgorithm implements Algorithm {
  DfsAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    final rows = matrix.length;
    final columns = matrix[0].length;
    final changes = <Change>[];

    final grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => DfsNode(row, col, matrix[row][col]),
      ),
    );

    DfsNode? startNode;
    DfsNode? endNode;
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

    final stack = <DfsNode>[startNode];
    final visited = <DfsNode>{};

    while (stack.isNotEmpty) {
      final currentNode = stack.removeLast();

      if (visited.contains(currentNode)) continue;
      visited.add(currentNode);

      changes.add(
          Change(currentNode.row, currentNode.column, BlockState.visited));

      if (currentNode == endNode) {
        final path = constructPath(currentNode);
        return AlgorithmResult(changes, path);
      }

      for (final neighbor in currentNode.getNeighbors(grid, rows, columns)) {
        if (!visited.contains(neighbor) &&
            neighbor.blockState != BlockState.wall) {
          neighbor.cameFrom = currentNode;
          stack.add(neighbor);
        }
      }
    }

    return AlgorithmResult(changes, null);
  }

  @override
  String name = "DFS";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Algorithm && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class DfsNode extends PathNode {
  BlockState blockState;

  DfsNode(int row, int column, this.blockState) : super(row, column);

  List<DfsNode> getNeighbors(
      List<List<DfsNode>> grid, int rows, int columns) {
    final neighbors = <DfsNode>[];
    if (row > 0) neighbors.add(grid[row - 1][column]);
    if (row < rows - 1) neighbors.add(grid[row + 1][column]);
    if (column > 0) neighbors.add(grid[row][column - 1]);
    if (column < columns - 1) neighbors.add(grid[row][column + 1]);

    return neighbors
        .where((node) => node.blockState != BlockState.wall)
        .toList();
  }
}
