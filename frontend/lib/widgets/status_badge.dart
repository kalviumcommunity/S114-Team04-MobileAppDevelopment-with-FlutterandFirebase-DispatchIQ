import 'package:flutter/material.dart';

import '../app/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StatusColor {
  static const Color available = AppTheme.green;
  static const Color onRoute = AppTheme.primary;
  static const Color busy = AppTheme.amber;
  static const Color offline = AppTheme.muted;
  static const Color unassigned = AppTheme.muted;
  static const Color assigned = AppTheme.primary;
  static const Color delayed = AppTheme.red;
  static const Color done = AppTheme.green;
  static const Color repeat = AppTheme.amber;
}
