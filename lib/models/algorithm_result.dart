import 'package:path_finding/algorithm/algorithm_path.dart';
import 'package:path_finding/models/change.dart';

class AlgorithmResult {
  final List<Change> changes;
  final AlgorithmPath? path;

  AlgorithmResult(this.changes, this.path);
}
