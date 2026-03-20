import 'package:flutter/material.dart';
import 'package:path_finding/algorithm/a_star.dart';
import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/bfs.dart';
import 'package:path_finding/algorithm/bidirectional_bfs.dart';
import 'package:path_finding/algorithm/dfs.dart';
import 'package:path_finding/algorithm/dijkstra.dart';
import 'package:path_finding/algorithm/greedy_best_first.dart';

class Algorithms extends StatelessWidget {
  final Function(Algorithm) onChanged;
  final Algorithm value;
  const Algorithms({
    required this.onChanged,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Algorithm>(
      value: value,
      items: [
        DropdownMenuItem<Algorithm>(
          value: DijkstraAlgorithm(),
          child: const Text('Dijkstra'),
        ),
        DropdownMenuItem<Algorithm>(
          value: AStarAlgorithm(),
          child: const Text('A*'),
        ),
        DropdownMenuItem<Algorithm>(
          value: BfsAlgorithm(),
          child: const Text('BFS'),
        ),
        DropdownMenuItem<Algorithm>(
          value: DfsAlgorithm(),
          child: const Text('DFS'),
        ),
        DropdownMenuItem<Algorithm>(
          value: GreedyBestFirstAlgorithm(),
          child: const Text('Greedy Best-First'),
        ),
        DropdownMenuItem<Algorithm>(
          value: BidirectionalBfsAlgorithm(),
          child: const Text('Bidirectional BFS'),
        ),
      ],
      onChanged: (Algorithm? value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
