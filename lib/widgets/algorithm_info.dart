import 'package:flutter/material.dart';
import 'package:path_finding/algorithm/algorithm.dart';

class AlgorithmInfo {
  final String name;
  final String shortDescription;
  final String howItWorks;
  final String guarantees;
  final IconData icon;

  const AlgorithmInfo({
    required this.name,
    required this.shortDescription,
    required this.howItWorks,
    required this.guarantees,
    required this.icon,
  });
}

const Map<String, AlgorithmInfo> algorithmInfoMap = {
  'Dijkstra': AlgorithmInfo(
    name: 'Dijkstra',
    shortDescription: 'Explores all directions equally, like a ripple in water.',
    howItWorks:
        'Dijkstra\'s algorithm picks the unvisited node with the smallest known distance from the start, then updates its neighbors. It expands outward uniformly in all directions until it reaches the end.',
    guarantees: 'Always finds the shortest path.',
    icon: Icons.waves,
  ),
  'A*': AlgorithmInfo(
    name: 'A* (A-Star)',
    shortDescription: 'Smart search that uses distance estimation to find the goal faster.',
    howItWorks:
        'A* combines the actual distance traveled (like Dijkstra) with a heuristic estimate of the remaining distance (Manhattan distance). This guides the search toward the goal while still guaranteeing the shortest path.',
    guarantees: 'Always finds the shortest path.',
    icon: Icons.star,
  ),
  'BFS': AlgorithmInfo(
    name: 'Breadth-First Search',
    shortDescription: 'Explores layer by layer, checking all neighbors before going deeper.',
    howItWorks:
        'BFS uses a queue (FIFO) to visit nodes. It explores all nodes at distance 1 from the start, then all nodes at distance 2, and so on. This layer-by-layer approach ensures the first path found is the shortest.',
    guarantees: 'Always finds the shortest path.',
    icon: Icons.layers,
  ),
  'DFS': AlgorithmInfo(
    name: 'Depth-First Search',
    shortDescription: 'Dives deep into one path before backtracking to try others.',
    howItWorks:
        'DFS uses a stack (LIFO) to visit nodes. It picks a direction and goes as far as possible before hitting a dead end, then backtracks to try alternative routes. This creates a winding, maze-like exploration pattern.',
    guarantees: 'Finds a path, but NOT necessarily the shortest one.',
    icon: Icons.arrow_downward,
  ),
  'Greedy Best-First': AlgorithmInfo(
    name: 'Greedy Best-First Search',
    shortDescription: 'Always moves toward the goal, ignoring the cost so far.',
    howItWorks:
        'Greedy Best-First uses only the heuristic (estimated distance to goal) to decide which node to visit next. It aggressively moves toward the end node, which makes it fast but it can be fooled by walls into taking longer paths.',
    guarantees: 'Finds a path quickly, but NOT necessarily the shortest one.',
    icon: Icons.fast_forward,
  ),
  'Bidirectional BFS': AlgorithmInfo(
    name: 'Bidirectional BFS',
    shortDescription: 'Searches from both the start and end simultaneously until they meet.',
    howItWorks:
        'Two BFS searches run in parallel — one expanding from the start and one from the end. When the two search frontiers meet, the path is reconstructed by joining the two halves. This dramatically reduces the number of nodes explored.',
    guarantees: 'Always finds the shortest path.',
    icon: Icons.compare_arrows,
  ),
};

class AlgorithmInfoPanel extends StatelessWidget {
  final Algorithm algorithm;

  const AlgorithmInfoPanel({super.key, required this.algorithm});

  @override
  Widget build(BuildContext context) {
    final info = algorithmInfoMap[algorithm.name];
    if (info == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(info.icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                info.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.shortDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.howItWorks,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: info.guarantees.contains('NOT')
                  ? colorScheme.errorContainer.withValues(alpha: 0.5)
                  : colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              info.guarantees,
              style: theme.textTheme.labelSmall?.copyWith(
                color: info.guarantees.contains('NOT')
                    ? colorScheme.error
                    : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
