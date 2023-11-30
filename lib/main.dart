import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_finding/algorithm/a_star.dart';
import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/action_button_widget.dart';
import 'package:path_finding/widgets/algorithms.dart';
import 'package:path_finding/widgets/grid.dart';
import 'package:path_finding/models/models.dart';
import 'package:path_finding/widgets/speed_control_slider.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Path Finding Visualizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedAction = 'none';
  Algorithm _algorithm = AStarAlgorithm();
  Duration timeBetweenChanges = const Duration(milliseconds: 20);
  void _handleAction(String action) {
    setState(() {
      _selectedAction = _selectedAction == action ? 'none' : action;
    });
    final controller = GridController();
    if (_selectedAction == 'none') {
      controller.cursorType = CursorType.none;
      return;
    }
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
      case 'eraser':
        controller.cursorType = CursorType.eraser;
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
        title: Text(widget.title),
        actions: [
          // Spacer(),
          Algorithms(
            onChanged: (Algorithm algorithm) {
              setState(() {
                _algorithm = algorithm;
              });
            },
            value: _algorithm,
          ),
          const SizedBox(
            width: 10,
          ),

          SpeedControlSlider(
              slowestSpeedDuration: const Duration(milliseconds: 300),
              fastestSpeedDuration: const Duration(milliseconds: 1),
              currentValue: timeBetweenChanges,
              onChanged: (Duration timeBetweenChanges) {
                setState(() {
                  this.timeBetweenChanges = timeBetweenChanges;
                });
              }),
        ],
      ),
      body: Center(
        child: Grid(
          horizontalBlockCount: GridController().rows,
          verticalBlockCount: GridController().columns,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ActionButtonWidget(
            action: 'start',
            label: 'Start',
            selectedAction: _selectedAction,
            handleAction: _handleAction,
            isCursorType: true,
          ),
          const SizedBox(height: 10),
          ActionButtonWidget(
            action: 'end',
            label: 'End',
            selectedAction: _selectedAction,
            handleAction: _handleAction,
            isCursorType: true,
          ),
          const SizedBox(height: 10),
          ActionButtonWidget(
            action: 'wall',
            label: 'Wall',
            selectedAction: _selectedAction,
            handleAction: _handleAction,
            isCursorType: true,
          ),
          const SizedBox(height: 10),
          ActionButtonWidget(
            action: 'eraser',
            label: 'Eraser',
            selectedAction: _selectedAction,
            handleAction: _handleAction,
            isCursorType: true,
          ),
          const SizedBox(height: 25),
          ActionButtonWidget(
            action: 'reset',
            label: 'Reset',
            icon: Icons.refresh,
            selectedAction: _selectedAction,
            handleAction: _handleAction,
            isCursorType: false,
          ),
          const SizedBox(height: 10),
          ActionButtonWidget(
            action: 'startAlgorithm',
            label: 'Start',
            icon: Icons.play_arrow,
            selectedAction: _selectedAction,
            handleAction: _handleAction,
            isCursorType: false,
          ),
        ],
      ),
    );
  }

  void _startAlgorithm() {
    final controller = GridController();
    AlgorithmResult result = _algorithm.execute(controller.getMatrixValues());
    controller.applyAlgorithmResult(result,
        timeBetweenChanges: timeBetweenChanges);
  }
}
