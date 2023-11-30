import 'package:flutter/material.dart';
import 'package:path_finding/algorithm/a_star.dart';
import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/algorithm/dijkstra.dart';

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
      ],
      onChanged: (Algorithm? value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
