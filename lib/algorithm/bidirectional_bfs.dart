import 'dart:collection';

import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/node/path_node.dart';
import 'package:path_finding/models/models.dart';

class BidirectionalBfsAlgorithm implements Algorithm {
  BidirectionalBfsAlgorithm() : super();

  @override
  AlgorithmResult execute(List<List<BlockState>> matrix) {
    final rows = matrix.length;
    final columns = matrix[0].length;
    final changes = <Change>[];

    final grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => BiNode(row, col, matrix[row][col]),
      ),
    );

    BiNode? startNode;
    BiNode? endNode;
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

    final forwardQueue = Queue<BiNode>();
    final backwardQueue = Queue<BiNode>();
    final forwardVisited = <BiNode>{};
    final backwardVisited = <BiNode>{};
    final forwardParent = <BiNode, BiNode?>{};
    final backwardParent = <BiNode, BiNode?>{};

    forwardQueue.add(startNode);
    forwardVisited.add(startNode);
    forwardParent[startNode] = null;

    backwardQueue.add(endNode);
    backwardVisited.add(endNode);
    backwardParent[endNode] = null;

    while (forwardQueue.isNotEmpty && backwardQueue.isNotEmpty) {
      // Expand forward
      final meetingFromForward =
          _expandLevel(forwardQueue, forwardVisited, forwardParent,
              backwardVisited, grid, rows, columns, changes);
      if (meetingFromForward != null) {
        final path = _buildPath(
            meetingFromForward, forwardParent, backwardParent);
        return AlgorithmResult(changes, path);
      }

      // Expand backward
      final meetingFromBackward =
          _expandLevel(backwardQueue, backwardVisited, backwardParent,
              forwardVisited, grid, rows, columns, changes);
      if (meetingFromBackward != null) {
        final path = _buildPath(
            meetingFromBackward, forwardParent, backwardParent);
        return AlgorithmResult(changes, path);
      }
    }

    return AlgorithmResult(changes, null);
  }

  BiNode? _expandLevel(
    Queue<BiNode> queue,
    Set<BiNode> visited,
    Map<BiNode, BiNode?> parent,
    Set<BiNode> oppositeVisited,
    List<List<BiNode>> grid,
    int rows,
    int columns,
    List<Change> changes,
  ) {
    final levelSize = queue.length;
    for (var i = 0; i < levelSize; i++) {
      final currentNode = queue.removeFirst();
      changes.add(
          Change(currentNode.row, currentNode.column, BlockState.visited));

      for (final neighbor
          in currentNode.getNeighbors(grid, rows, columns)) {
        if (neighbor.blockState == BlockState.wall) continue;

        if (oppositeVisited.contains(neighbor)) {
          parent[neighbor] = currentNode;
          return neighbor;
        }

        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          parent[neighbor] = currentNode;
          queue.add(neighbor);
          changes.add(
              Change(neighbor.row, neighbor.column, BlockState.visited));
        }
      }
    }
    return null;
  }

  AlgorithmPath _buildPath(
    BiNode meetingNode,
    Map<BiNode, BiNode?> forwardParent,
    Map<BiNode, BiNode?> backwardParent,
  ) {
    final forwardRows = <int>[];
    final forwardCols = <int>[];
    BiNode? current = meetingNode;

    // Build forward path (meeting -> start), then reverse
    while (current != null && forwardParent.containsKey(current)) {
      forwardRows.insert(0, current.row);
      forwardCols.insert(0, current.column);
      current = forwardParent[current];
    }

    // Build backward path (meeting -> end)
    current = backwardParent[meetingNode];
    while (current != null) {
      forwardRows.add(current.row);
      forwardCols.add(current.column);
      current = backwardParent[current];
    }

    return AlgorithmPath(forwardRows, forwardCols);
  }

  @override
  String name = "Bidirectional BFS";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Algorithm && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class BiNode extends PathNode {
  BlockState blockState;

  BiNode(int row, int column, this.blockState) : super(row, column);

  List<BiNode> getNeighbors(
      List<List<BiNode>> grid, int rows, int columns) {
    final neighbors = <BiNode>[];
    if (row > 0) neighbors.add(grid[row - 1][column]);
    if (row < rows - 1) neighbors.add(grid[row + 1][column]);
    if (column > 0) neighbors.add(grid[row][column - 1]);
    if (column < columns - 1) neighbors.add(grid[row][column + 1]);

    return neighbors
        .where((node) => node.blockState != BlockState.wall)
        .toList();
  }
}
