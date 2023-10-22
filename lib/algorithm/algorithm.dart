import 'package:path_finding/models/algorithm_result.dart';
import 'package:path_finding/models/block_state.dart';

abstract class Algorithm {
  Algorithm();

  AlgorithmResult execute(List<List<BlockState>> matrix);
}
