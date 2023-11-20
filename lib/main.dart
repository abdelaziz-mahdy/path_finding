import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_finding/algorithm/a_star.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/action_button.dart';
import 'package:path_finding/widgets/expandable_fab.dart';
import 'package:path_finding/widgets/grid.dart';
import 'package:path_finding/models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.remove();
  GridController();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Finding Visualizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Path Finding Visualizer'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  void _handleAction(String action) {
    final controller = GridController();
    switch (action) {
      case 'start':
        controller.cursorType = CursorType.start;
        break;
      case 'end':
        controller.cursorType = CursorType.end;
        break;
      case 'wall':
        controller.cursorType = CursorType.wall;
        break;
      case 'reset':
        controller.resetMatrix();
        break;
      case 'startAlgorithm':
        _startAlgorithm();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Grid(
          horizontalBlockCount: GridController().rows,
          verticalBlockCount: GridController().columns,
        ),
      ),
      floatingActionButton: ExpandableFab(
        distance: max(100, MediaQuery.sizeOf(context).width * 0.15),
        children: [
          ActionButton(
            onPressed: () => _handleAction('start'),
            icon: const Text(
              "Start",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ActionButton(
            onPressed: () => _handleAction('end'),
            icon: const Text(
              "End",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ActionButton(
            onPressed: () => _handleAction('wall'),
            icon: const Text(
              "Wall",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ActionButton(
            onPressed: () => _handleAction('reset'),
            icon: const Text(
              "Reset",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ActionButton(
            onPressed: () => _handleAction('startAlgorithm'),
            icon: const Text(
              "Run",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _startAlgorithm() {
    final controller = GridController();
    // Perform the algorithm execution using the controller's matrix
    AlgorithmResult result =
        AStarAlgorithm().execute(controller.getMatrixValues());
    print("ended");
    print("ended ${result.changes}");
    print("ended ${result.path}");

    // You can access the changes and path from the result object and perform necessary actions
    controller.applyAlgorithmResult(result);
  }
}
