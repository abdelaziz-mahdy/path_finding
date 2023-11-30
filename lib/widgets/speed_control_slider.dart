import 'package:flutter/material.dart';

/// A custom Flutter slider widget to control speed represented as a duration.
///
/// The slider allows users to select a speed, where the left side of the slider
/// represents a slower speed (higher duration) and the right side represents
/// a faster speed (lower duration).
class SpeedControlSlider extends StatelessWidget {
  /// The duration representing the slowest speed (highest duration).
  final Duration slowestSpeedDuration;

  /// The duration representing the fastest speed (lowest duration).
  final Duration fastestSpeedDuration;

  /// The current value of the slider represented as a duration.
  final Duration currentValue;

  /// Callback function called when the slider value changes.
  final Function(Duration) onChanged;

  const SpeedControlSlider({
    Key? key,
    required this.slowestSpeedDuration,
    required this.fastestSpeedDuration,
    required this.currentValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the range and initial value for the slider.
    final int totalDurationRange = slowestSpeedDuration.inMilliseconds -
        fastestSpeedDuration.inMilliseconds;
    final double initialSliderValue =
        (currentValue.inMilliseconds - fastestSpeedDuration.inMilliseconds) /
            totalDurationRange;

    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Fast'),
        Slider(
          value: initialSliderValue,
          min: 0.0,
          max: 1.0,
          divisions: totalDurationRange ~/
              10, // Divisions based on the range in seconds.
          onChanged: (double value) {
            // Map the slider value to the duration range.
            var durationValue = fastestSpeedDuration.inMilliseconds +
                value * totalDurationRange;
            onChanged(Duration(milliseconds: durationValue.round()));
          },
          // label: 'Speed',
          // activeColor: Colors.blue,
          // inactiveColor: Colors.blue.withOpacity(0.3),
        ),
        const Text('Slow'),
      ],
    );
  }
}
