// lib/widgets/chip_list_widget.dart
import 'package:flutter/material.dart';

class ChipListWidget extends StatelessWidget {
  final List<String> items;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const ChipListWidget({
    super.key,
    required this.items,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Chip(
          label: Text(
            item,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              color: textColor,
            ),
          ),
          backgroundColor: backgroundColor ?? Colors.grey[200],
          padding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}

