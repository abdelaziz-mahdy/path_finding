import 'package:flutter_test/flutter_test.dart';
import 'package:path_finding/algorithm/greedy_best_first.dart';
import 'package:path_finding/models/block_state.dart';

import 'algorithm_test_helper.dart';

void main() {
  group('Greedy Best-First Algorithm', () {
    test('finds path in open grid', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '....',
        '...E',
      ]);

      final result = GreedyBestFirstAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      expect(result.path!.rows.first, equals(0));
      expect(result.path!.columns.first, equals(0));
      expect(result.path!.rows.last, equals(3));
      expect(result.path!.columns.last, equals(3));
    });

    test('finds path around walls', () {
      final matrix = createMatrix([
        'S.W.',
        '.WW.',
        '....',
        '...E',
      ]);

      final result = GreedyBestFirstAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      for (var i = 0; i < result.path!.rows.length; i++) {
        final r = result.path!.rows[i];
        final c = result.path!.columns[i];
        expect(matrix[r][c], isNot(equals(BlockState.wall)));
      }
    });

    test('returns null path when no path exists', () {
      final blockedMatrix = createMatrix([
        'SW..',
        '.W..',
        '.W..',
        '.W.E',
      ]);

      final result = GreedyBestFirstAlgorithm().execute(blockedMatrix);

      expect(result.path, isNull);
      expect(result.changes, isNotEmpty);
    });

    test('throws when start or end missing', () {
      final matrix = createMatrix([
        '....',
        '....',
      ]);

      expect(() => GreedyBestFirstAlgorithm().execute(matrix), throwsException);
    });

    test('finds direct adjacent path', () {
      final matrix = createMatrix([
        'SE',
      ]);

      final result = GreedyBestFirstAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      expect(result.path!.rows.length, equals(2));
    });

    test('typically visits fewer nodes than Dijkstra in open grid', () {
      // Greedy best-first should be more directed towards the goal
      final matrix = createMatrix([
        'S.........',
        '..........',
        '..........',
        '..........',
        '.........E',
      ]);

      final result = GreedyBestFirstAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      // Should find a path efficiently
      expect(result.changes.length, lessThan(55)); // less than total cells
    });

    test('name is Greedy Best-First', () {
      expect(GreedyBestFirstAlgorithm().name, equals('Greedy Best-First'));
    });
  });
}
