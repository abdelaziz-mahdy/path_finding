import 'package:path_finding/controller.dart';

import 'algorithm.dart';

class AStarAlgorithm implements Algorithm {
  AStarAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    // Retrieve the dimensions of the matrix
    final int rows = matrix.length;
    final int columns = matrix[0].length;

    // Create a 2D grid to track the nodes
    final List<List<AStarNode>> grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => AStarNode(row, col),
      ),
    );

    // Retrieve the start and end nodes from the matrix
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

    // Initialize the open and closed sets for node traversal
    final List<AStarNode> openSet = [];
    final List<AStarNode> closedSet = [];
    if (startNode == null) {
      throw Exception("Start node needs to be set");
    }
    if (endNode == null) {
      throw Exception("End node needs to be set");
    }
    // Add the start node to the open set
    openSet.add(startNode);

    while (openSet.isNotEmpty) {
      // Find the node with the lowest fScore in the open set
      final currentNode = openSet.reduce((a, b) => a.fScore < b.fScore ? a : b);

      // If the current node is the end node, construct the path
      if (currentNode == endNode) {
        final path = constructPath(currentNode);
        final changes = matrixToChanges(matrix);
        return AlgorithmResult(changes, path);
      }

      // Remove the current node from the open set and add it to the closed set
      openSet.remove(currentNode);
      closedSet.add(currentNode);

      // Explore the neighbors of the current node
      for (final neighbor in currentNode.getNeighbors(grid, rows, columns)) {
        // Skip neighbors that are already in the closed set or are walls
        if (closedSet.contains(neighbor) ||
            neighbor.blockState == BlockState.wall) {
          continue;
        }

        // Calculate the tentative gScore and update the neighbor if it's a better path
        final tentativeGScore = currentNode.gScore + 1;
        if (tentativeGScore < neighbor.gScore) {
          neighbor.cameFrom = currentNode;
          neighbor.gScore = tentativeGScore;
          neighbor.calculateFScore(endNode);
        }

        // Add the neighbor to the open set if it's not already there
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }

        // Mark the neighbor as visited in the matrix
        matrix[neighbor.row][neighbor.column] = BlockState.visited;
      }
    }

    // No path found
    return AlgorithmResult([], null);
  }

  // Converts the matrix to a list of changes for visited nodes
  List<Change> matrixToChanges(List<List<BlockState>> matrix) {
    final List<Change> changes = [];
    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        final BlockState blockState = matrix[row][col];
        if (blockState == BlockState.visited) {
          changes.add(Change(row, col, BlockState.visited));
        }
      }
    }
    return changes;
  }
}

// Constructs the path by backtracking from the end node
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
  int gScore;
  int hScore;
  int fScore;

  AStarNode(this.row, this.column)
      : blockState = BlockState.none,
        cameFrom = null,
        gScore = 0,
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

  List<AStarNode> getNeighbors(
      List<List<AStarNode>> grid, int rows, int columns) {
    final List<AStarNode> neighbors = [];

    if (row > 0 && grid[row - 1][column].blockState != BlockState.wall) {
      neighbors.add(grid[row - 1][column]); // Top
    }
    if (row < rows - 1 && grid[row + 1][column].blockState != BlockState.wall) {
      neighbors.add(grid[row + 1][column]); // Bottom
    }
    if (column > 0 && grid[row][column - 1].blockState != BlockState.wall) {
      neighbors.add(grid[row][column - 1]); // Left
    }
    if (column < columns - 1 &&
        grid[row][column + 1].blockState != BlockState.wall) {
      neighbors.add(grid[row][column + 1]); // Right
    }

    return neighbors;
  }
}
