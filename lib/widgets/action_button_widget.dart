import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final String action;
  final String label;
  final IconData? icon;
  final String selectedAction;
  final Function(String) handleAction;
  final bool isCursorType;

  const ActionButtonWidget({
    Key? key,
    this.icon,
    required this.action,
    required this.label,
    required this.selectedAction,
    required this.handleAction,
    required this.isCursorType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedAction == action;
    TextStyle textStyle = TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSecondary);
    Color backgroundColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    if (!isCursorType) {
      textStyle =
          TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer);
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    }

    return FloatingActionButton(
      onPressed: () => handleAction(action),
      backgroundColor: backgroundColor,
      child: icon != null
          ? Icon(icon, color: textStyle.color)
          : Text(label, style: textStyle),
    );
  }
}
