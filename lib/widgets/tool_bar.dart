import 'package:flutter/material.dart';
import 'package:path_finding/models/cursor_type.dart';

class ToolBar extends StatelessWidget {
  final CursorType selectedTool;
  final ValueChanged<CursorType> onToolChanged;
  final VoidCallback onReset;
  final VoidCallback onStart;

  const ToolBar({
    super.key,
    required this.selectedTool,
    required this.onToolChanged,
    required this.onReset,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ToolChip(
                      icon: Icons.location_on,
                      label: 'Start',
                      color: const Color(0xFF4CAF50),
                      isSelected: selectedTool == CursorType.start,
                      onTap: () => onToolChanged(
                          selectedTool == CursorType.start
                              ? CursorType.none
                              : CursorType.start),
                    ),
                    const SizedBox(width: 6),
                    _ToolChip(
                      icon: Icons.flag,
                      label: 'End',
                      color: const Color(0xFFE53935),
                      isSelected: selectedTool == CursorType.end,
                      onTap: () => onToolChanged(selectedTool == CursorType.end
                          ? CursorType.none
                          : CursorType.end),
                    ),
                    const SizedBox(width: 6),
                    _ToolChip(
                      icon: Icons.square_rounded,
                      label: 'Wall',
                      color: const Color(0xFF37474F),
                      isSelected: selectedTool == CursorType.wall,
                      onTap: () => onToolChanged(
                          selectedTool == CursorType.wall
                              ? CursorType.none
                              : CursorType.wall),
                    ),
                    const SizedBox(width: 6),
                    _ToolChip(
                      icon: Icons.auto_fix_high,
                      label: 'Eraser',
                      color: colorScheme.tertiary,
                      isSelected: selectedTool == CursorType.eraser,
                      onTap: () => onToolChanged(
                          selectedTool == CursorType.eraser
                              ? CursorType.none
                              : CursorType.eraser),
                    ),
                    const SizedBox(width: 12),
                    _ActionChip(
                      icon: Icons.refresh_rounded,
                      label: 'Clear',
                      color: colorScheme.outline,
                      onTap: onReset,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Run'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
