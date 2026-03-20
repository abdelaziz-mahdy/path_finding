import 'package:flutter_test/flutter_test.dart';
import 'package:path_finding/algorithm/bfs.dart';
import 'package:path_finding/models/block_state.dart';

import 'algorithm_test_helper.dart';

void main() {
  group('BFS Algorithm', () {
    test('finds path in open grid', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '....',
        '...E',
      ]);

      final result = BfsAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      // BFS guarantees shortest path: Manhattan distance is 6
      expect(result.path!.rows.length, equals(7)); // 7 cells including start+end
      // Start should be first
      expect(result.path!.rows.first, equals(0));
      expect(result.path!.columns.first, equals(0));
      // End should be last
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

      final result = BfsAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      // Verify path doesn't go through walls
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

      final result = BfsAlgorithm().execute(blockedMatrix);

      expect(result.path, isNull);
      expect(result.changes, isNotEmpty);
    });

    test('throws when start or end missing', () {
      final matrix = createMatrix([
        '....',
        '....',
      ]);

      expect(() => BfsAlgorithm().execute(matrix), throwsException);
    });

    test('finds direct adjacent path', () {
      final matrix = createMatrix([
        'SE',
      ]);

      final result = BfsAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      expect(result.path!.rows.length, equals(2));
    });

    test('produces visited changes during execution', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '...E',
      ]);

      final result = BfsAlgorithm().execute(matrix);

      expect(result.changes, isNotEmpty);
      for (final change in result.changes) {
        expect(change.newState, equals(BlockState.visited));
      }
    });

    test('name is BFS', () {
      expect(BfsAlgorithm().name, equals('BFS'));
    });
  });
}
