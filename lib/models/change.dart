import 'package:path_finding/models/block_state.dart';

class Change {
  final int row;
  final int column;
  final BlockState newState;

  Change(this.row, this.column, this.newState);
}
