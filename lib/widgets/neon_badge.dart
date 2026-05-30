import 'package:flutter/material.dart';

class NeonBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const NeonBadge({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14.0,
              color: color,
            ),
            const SizedBox(width: 6.0),
          ],
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              shadows: [
                Shadow(
                  color: color,
                  blurRadius: 3.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
