import 'package:flutter_test/flutter_test.dart';
import 'package:path_finding/algorithm/dijkstra.dart';
import 'package:path_finding/models/block_state.dart';

import 'algorithm_test_helper.dart';

void main() {
  group('Dijkstra Algorithm', () {
    test('finds shortest path in open grid', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '....',
        '...E',
      ]);

      final result = DijkstraAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      expect(result.path!.rows.length, equals(7));
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

      final result = DijkstraAlgorithm().execute(matrix);

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

      final result = DijkstraAlgorithm().execute(blockedMatrix);

      expect(result.path, isNull);
    });

    test('throws when start or end missing', () {
      final matrix = createMatrix([
        '....',
        '....',
      ]);

      expect(() => DijkstraAlgorithm().execute(matrix), throwsException);
    });

    test('finds direct adjacent path', () {
      final matrix = createMatrix([
        'SE',
      ]);

      final result = DijkstraAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      expect(result.path!.rows.length, equals(2));
    });

    test('name is Dijkstra', () {
      expect(DijkstraAlgorithm().name, equals('Dijkstra'));
    });
  });
}
