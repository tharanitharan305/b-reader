import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class SplWidget extends StatelessWidget {
  final PageElement element;

  const SplWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final style = element.style;
    final data = element.data;

    return DottedBorder(

options: RectDottedBorderOptions(
  color: Colors.purple,
  strokeWidth: 1.5,
  dashPattern: const [6, 3], // ← dotted spacing
),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          style.paddingLeft ?? 0,
          style.paddingTop ?? 0,
          style.paddingRight ?? 0,
          style.paddingBottom ?? 0,
        ),
        color: _parseColor(style.background),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.title != null)
              Text(
                data.title!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: style.fontSize,
                  fontFamily:style.fontFamily
                ),
              ),

            const SizedBox(height: 8),

            ...?data.points?.map(
                  (point) => Padding(
                padding: EdgeInsets.fromLTRB(
                  style.paddingLeft ?? 0,
                  style.paddingTop ?? 0,
                  style.paddingRight ?? 0,
                  style.paddingBottom ?? 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    Expanded(child: Text(point, style:  TextStyle(fontSize: style.fontSize,
                        fontFamily:style.fontFamily))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
