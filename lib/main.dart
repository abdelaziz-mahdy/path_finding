import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_finding/Algorithms/A_start.dart';
import 'package:path_finding/Algorithms/algorithm.dart';
import 'package:path_finding/controller.dart';
import 'package:path_finding/grid.dart';

void main() {
  Get.put(GridController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Grid(
          horizontalBlockCount: Get.find<GridController>().rows,
          verticalBlockCount: Get.find<GridController>().columns,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenu(context),
        tooltip: 'Options',
        child: const Icon(Icons.settings),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final controller = Get.find<GridController>();
    final menuItems = [
      PopupMenuItem(
        value: 'start',
        child: const Text('Set Start Point'),
      ),
      PopupMenuItem(
        value: 'end',
        child: const Text('Set End Point'),
      ),
      PopupMenuItem(
        value: 'wall',
        child: const Text('Add Wall'),
      ),
      PopupMenuItem(
        value: 'reset',
        child: const Text('Reset'),
      ),
      PopupMenuItem(
        value: 'startAlgorithm',
        child: const Text('Start Algorithm'),
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(16.0, kToolbarHeight, 16.0, 0.0),
      items: menuItems,
      elevation: 8.0,
    ).then((value) {
      if (value == 'start') {
        controller.cursorType = CursorType.start;
      } else if (value == 'end') {
        controller.cursorType = CursorType.end;
      } else if (value == 'wall') {
        controller.cursorType = CursorType.wall;
      } else if (value == 'reset') {
        controller.resetMatrix();
      } else if (value == 'startAlgorithm') {
        // Start the algorithm
        _startAlgorithm();
      }
    });
  }

  void _startAlgorithm() {
    final controller = Get.find<GridController>();
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
