import 'package:path_finding/controller.dart';

abstract class Algorithm {
  Algorithm();

  AlgorithmResult execute(List<List<BlockState>> matrix);
}

class AlgorithmResult {
  final List<Change> changes;
  final AlgorithmPath? path;

  AlgorithmResult(this.changes, this.path);
}

class Change {
  final int row;
  final int column;
  final BlockState newState;

  Change(this.row, this.column, this.newState);
}

class AlgorithmPath {
  final List<int> rows;
  final List<int> columns;

  AlgorithmPath(this.rows, this.columns);
}
