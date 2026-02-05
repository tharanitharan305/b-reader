import 'dart:developer';

import 'package:flutter/material.dart';
import 'models.dart';

class BTable extends StatelessWidget {
  final PageElement element;
  final Widget Function(PageElement, {bool insideTable}) renderRecursive;

  const BTable({
    super.key,
    required this.element,
    required this.renderRecursive,
  });

  @override
  Widget build(BuildContext context) {

    if (element.rows == null || element.rows!.isEmpty) {
      return const SizedBox.shrink();
    }

    final borderSide = BorderSide(
      color: Colors.grey.withOpacity(0.5),
      width: 1,
    );

    // 1. Wrap in Align to prevent forced stretching to screen width
    return Align(
      alignment: Alignment.topLeft,
      child: Container(

        child: Table(

          defaultColumnWidth: const IntrinsicColumnWidth(),

          border: TableBorder(
            top: borderSide,
            bottom: borderSide,
            left: borderSide,
            right: borderSide,
            horizontalInside: borderSide,
            verticalInside: borderSide,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: element.rows!.map((rowCells) {
            return TableRow(
              children: rowCells.map((cellElement) {
                return _buildCellContent(cellElement);
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCellContent(PageElement cell) {
    return Container(
      padding: EdgeInsets.only(
        top: cell.style.paddingTop ?? 4,
        bottom: cell.style.paddingBottom ?? 4,
        left: cell.style.paddingLeft ?? 4,
        right: cell.style.paddingRight ?? 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
        mainAxisSize: MainAxisSize.min, // Use minimum height
        children: cell.children.map((child) => renderRecursive(child,insideTable: true)).toList(),
      ),
    );
  }
}