import 'dart:developer';

import 'package:btab/videoElement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_all/flutter_html_all.dart';

import '3dModel.dart';
import 'audioElement.dart';
import 'models.dart';
class BPageView extends StatelessWidget {
  final PageData page;
  final int pageNumber;

  const BPageView({
    required this.page,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    final elements =
    page.layers.isNotEmpty ? page.layers.first.elements : <PageElement>[];

    // 🔥 Split elements
    final flow = <PageElement>[];
    final absolute = <PageElement>[];

    for (final e in elements) {
      if (e.frame != null || e.style.top != null || e.style.left != null) {
        absolute.add(e);
      } else {
        flow.add(e);
      }
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        width: page.size.width,
        height: page.size.height,
        color: _cssColor(page.background),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // FLOW CONTENT
            Padding(
              padding: const EdgeInsets.all(10),
              child: _buildFlow(flow),
            ),

            // ABSOLUTE CONTENT
            ...absolute.map(_buildAbsolute),
          ],
        ),
      ),
    );
  }

  /// ---------------- FLOW ----------------
  Widget _buildFlow(List<PageElement> elements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elements.map(_renderElement).toList(),
    );
  }

  /// ---------------- ABSOLUTE ----------------
  Widget _buildAbsolute(PageElement e) {
    final dx = e.frame?.x ?? e.style.left ?? 0;
    final dy = e.frame?.y ?? e.style.top ?? 0;

    log('${e.type.name} positioned at $dx , $dy');

    return Positioned(
      left: dx,
      top: dy,
      width: e.frame?.width ?? e.style.width,
      height: e.frame?.height ?? e.style.height,
      child: _renderElement(e),
    );
  }
  Color _cssColor(String? hex) {
    if (hex == null || hex.isEmpty || hex == 'transparent') {
      return Colors.transparent;
    }
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('0xff$clean'));
    } catch (_) {
      return Colors.black;
    }
  }

  /// ---------------- ELEMENT RENDERER ----------------
  Widget _renderElement(PageElement e) {
    Widget child;

    switch (e.type) {
      case ElementType.column:
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: e.children.map(_renderElement).toList(),
        );
        break;

      case ElementType.row:
        child = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: e.children.map(_renderElement).toList(),
        );
        break;

      case ElementType.text:
        child = Text(
          e.data.value ?? '',
          style: TextStyle(
            fontSize: e.style.fontSize ?? 16,
            fontWeight:
            e.style.fontWeight == 'bold' ? FontWeight.bold : FontWeight.normal,
            color: _cssColor(e.style.color),
          ),
        );
        break;

      case ElementType.image:
        child = Image.network(e.data.src ?? '');
        break;

      case ElementType.video:
        child = VideoElement(
          url: e.data.src ?? '',
          width: e.style.width,
          height: e.style.height,
        );
        break;

      case ElementType.audio:
        child = AudioElement(url: e.data.src ?? '');
        break;

      case ElementType.model3d:
        child = SizedBox(
          width: e.style.width,
          height: e.style.height,
          child: Model3DElement(src: e.data.src ?? ''),
        );
        break;

      case ElementType.math:
        child = Math.tex(
          e.data.value ?? '',
          textStyle: TextStyle(
            fontSize: e.style.fontSize ?? 18,
            color: _cssColor(e.style.color),
          ),
        );
        break;

      default:
        child = const SizedBox.shrink();
    }

    // 🔥 Padding
    return Padding(
      padding: EdgeInsets.only(
        top: e.style.paddingTop ?? 0,
        right: e.style.paddingRight ?? 0,
        bottom: e.style.paddingBottom ?? 0,
        left: e.style.paddingLeft ?? 0,
      ),
      child: child,
    );
  }
}
