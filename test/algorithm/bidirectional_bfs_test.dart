import 'package:flutter_test/flutter_test.dart';
import 'package:path_finding/algorithm/bidirectional_bfs.dart';
import 'package:path_finding/models/block_state.dart';

import 'algorithm_test_helper.dart';

void main() {
  group('Bidirectional BFS Algorithm', () {
    test('finds path in open grid', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '....',
        '...E',
      ]);

      final result = BidirectionalBfsAlgorithm().execute(matrix);

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

      final result = BidirectionalBfsAlgorithm().execute(matrix);

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

      final result = BidirectionalBfsAlgorithm().execute(blockedMatrix);

      expect(result.path, isNull);
      expect(result.changes, isNotEmpty);
    });

    test('throws when start or end missing', () {
      final matrix = createMatrix([
        '....',
        '....',
      ]);

      expect(
          () => BidirectionalBfsAlgorithm().execute(matrix), throwsException);
    });

    test('finds direct adjacent path', () {
      final matrix = createMatrix([
        'SE',
      ]);

      final result = BidirectionalBfsAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      expect(result.path!.rows.length, equals(2));
    });

    test('path contains start and end points', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '...E',
      ]);

      final result = BidirectionalBfsAlgorithm().execute(matrix);

      expect(result.path, isNotNull);
      // Path should start at S and end at E
      expect(result.path!.rows.first, equals(0));
      expect(result.path!.columns.first, equals(0));
      expect(result.path!.rows.last, equals(2));
      expect(result.path!.columns.last, equals(3));
    });

    test('produces visited changes during execution', () {
      final matrix = createMatrix([
        'S...',
        '....',
        '...E',
      ]);

      final result = BidirectionalBfsAlgorithm().execute(matrix);

      expect(result.changes, isNotEmpty);
      for (final change in result.changes) {
        expect(change.newState, equals(BlockState.visited));
      }
    });

    test('name is Bidirectional BFS', () {
      expect(
          BidirectionalBfsAlgorithm().name, equals('Bidirectional BFS'));
    });
  });
}
