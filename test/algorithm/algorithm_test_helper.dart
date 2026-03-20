import 'package:path_finding/models/block_state.dart';

/// Creates a matrix from a string representation.
/// Legend: S=start, E=end, W=wall, .=empty
List<List<BlockState>> createMatrix(List<String> rows) {
  return rows.map((row) {
    return row.split('').map((char) {
      switch (char) {
        case 'S':
          return BlockState.start;
        case 'E':
          return BlockState.end;
        case 'W':
          return BlockState.wall;
        case '.':
        default:
          return BlockState.none;
      }
    }).toList();
  }).toList();
}
