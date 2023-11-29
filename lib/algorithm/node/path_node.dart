abstract class PathNode {
  final int row;
  final int column;
  PathNode? cameFrom;

  PathNode(this.row, this.column);

  // You can add other common methods or properties here if needed
}
