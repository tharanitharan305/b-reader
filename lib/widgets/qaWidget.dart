import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import 'fillWidget.dart';
import 'mcqWidget.dart';
class QaWidget extends StatelessWidget {
  final List<QaItem> questions;
  final ElementStyle style;
  Function play;
  QaWidget({
    super.key,
    required this.questions,
    required this.style,
    required this.play
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main border box
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
          decoration: BoxDecoration(
            color: _hex(style.background) ?? const Color(0xFFF7F2FA),
            border: Border.all(color: Colors.purple),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildQuestions(),
          ),
        ),

        // Top border label (Q / A)
        Positioned(
          left: 12,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: _hex(style.background) ?? const Color(0xFFF7F2FA),
            child: const Text(
              'Q / A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuestions() {
    final widgets = <Widget>[];
    bool mcqHeaderShown = false;
    bool fillHeaderShown = false;

    for (final q in questions) {
      if (q is McqItem && !mcqHeaderShown) {
        widgets.add(_sectionTitle('A. Choose the correct answer'));
        mcqHeaderShown = true;
      }

      if (q is FillItem && !fillHeaderShown) {
        widgets.add(_sectionTitle('B. Fill in the blanks'));
        fillHeaderShown = true;
      }

      widgets.add(_buildItem(q));
    }

    return widgets;
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }


  Widget _buildItem(QaItem item) {
    switch (item.type) {
      case QaItemType.mcq:
        return McqWidget(item as McqItem,play);
      case QaItemType.fill:
        return FillWidget(item as FillItem);
      case QaItemType.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Divider(thickness: 1),
        );
    }
  }

  Color? _hex(String? h) =>
      h == null ? null : Color(int.parse(h.replaceFirst('#', '0xff')));
}

