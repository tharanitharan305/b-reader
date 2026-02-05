import 'package:flutter/material.dart';

import '../models.dart';

class FillWidget extends StatelessWidget {
  final FillItem item;

  const FillWidget(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: item.segments.map(_buildSegment).toList(),
      ),
    );
  }

  Widget _buildSegment(FillSegment segment) {
    if (segment is FillTextSegment) {
      return Text(
        segment.value.replaceAll(RegExp(r'\s+'), ' '),
      );

    }

    if (segment is FillBlankSegment) {
      return SizedBox(
        width: 70,
        child: TextField(
          decoration: const InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
