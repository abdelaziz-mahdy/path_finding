import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_finding/algorithms/a_star.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/grid.dart';
import 'package:path_finding/models/models.dart';

void main() {
  Get.put(GridController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key, required this.title});

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
      const PopupMenuItem(
        value: 'start',
        child: Text('Set Start Point'),
      ),
      const PopupMenuItem(
        value: 'end',
        child: Text('Set End Point'),
      ),
      const PopupMenuItem(
        value: 'wall',
        child: Text('Add Wall'),
      ),
      const PopupMenuItem(
        value: 'reset',
        child: Text('Reset'),
      ),
      const PopupMenuItem(
        value: 'startAlgorithm',
        child: Text('Start Algorithm'),
      ),
    ];

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(16.0, kToolbarHeight, 16.0, 0.0),
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
