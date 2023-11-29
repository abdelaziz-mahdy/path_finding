import 'package:path_finding/algorithm/algorithm_path.dart';
import 'package:path_finding/models/algorithm_result.dart';
import 'package:path_finding/models/block_state.dart';

import 'node/path_node.dart';

abstract class Algorithm {
  String name;
  Algorithm({required this.name});

  AlgorithmResult execute(List<List<BlockState>> matrix);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Algorithm && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

AlgorithmPath constructPath(PathNode? endNode) {
  if (endNode == null) {
    throw Exception("End node not found in path");
  }

  final List<int> rows = [];
  final List<int> columns = [];
  var currentNode = endNode;

  while (currentNode.cameFrom != null) {
    rows.insert(0, currentNode.row);
    columns.insert(0, currentNode.column);
    currentNode = currentNode.cameFrom!;
  }

  // Insert the start node's coordinates
  rows.insert(0, currentNode.row);
  columns.insert(0, currentNode.column);

  return AlgorithmPath(rows, columns);
}
