import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_finding/algorithm/a_star.dart';
import 'package:path_finding/algorithm/algorithm.dart';
import 'package:path_finding/controllers/controller.dart';
import 'package:path_finding/widgets/algorithm_info.dart';
import 'package:path_finding/widgets/algorithms.dart';
import 'package:path_finding/widgets/grid.dart';
import 'package:path_finding/models/models.dart';
import 'package:path_finding/widgets/speed_control_slider.dart';
import 'package:path_finding/widgets/tool_bar.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Algorithm _algorithm = AStarAlgorithm();
  CursorType _selectedTool = CursorType.wall;
  Duration _timeBetweenChanges = const Duration(milliseconds: 20);
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    GridController().cursorType = _selectedTool;
  }

  void _startAlgorithm() {
    final controller = GridController();
    AlgorithmResult result = _algorithm.execute(controller.getMatrixValues());
    controller.applyAlgorithmResult(result,
        timeBetweenChanges: _timeBetweenChanges);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.route_rounded, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Pathfinder',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Algorithms(
            onChanged: (Algorithm algorithm) {
              setState(() {
                _algorithm = algorithm;
              });
            },
            value: _algorithm,
          ),
          IconButton(
            icon: Icon(
              _showInfo ? Icons.info : Icons.info_outline,
              color: _showInfo ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Algorithm info',
            onPressed: () => setState(() => _showInfo = !_showInfo),
          ),
          const SizedBox(width: 8),
          SpeedControlSlider(
            slowestSpeedDuration: const Duration(milliseconds: 300),
            fastestSpeedDuration: const Duration(milliseconds: 1),
            currentValue: _timeBetweenChanges,
            onChanged: (Duration timeBetweenChanges) {
              setState(() {
                _timeBetweenChanges = timeBetweenChanges;
              });
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Algorithm info panel (collapsible)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _showInfo
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: AlgorithmInfoPanel(algorithm: _algorithm),
                  )
                : const SizedBox.shrink(),
          ),
          // Grid legend
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Color(0xFF4CAF50), label: 'Start'),
                SizedBox(width: 12),
                _LegendItem(color: Color(0xFFE53935), label: 'End'),
                SizedBox(width: 12),
                _LegendItem(color: Color(0xFF5C6B7A), label: 'Building'),
                SizedBox(width: 12),
                _LegendItem(
                    color: Color(0xFFB0BEC5), label: 'Explored'),
                SizedBox(width: 12),
                _LegendItem(
                    color: Color(0xFF2196F3), label: 'Route'),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Grid(
                  horizontalBlockCount: GridController().rows,
                  verticalBlockCount: GridController().columns,
                  borderColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          // Bottom toolbar
          ToolBar(
            selectedTool: _selectedTool,
            onToolChanged: (tool) {
              setState(() {
                _selectedTool = tool;
                GridController().cursorType = tool;
              });
            },
            onReset: () => GridController().resetMatrix(),
            onStart: _startAlgorithm,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
