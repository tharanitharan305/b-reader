import 'dart:developer';

import 'package:flutter/material.dart';
import 'models.dart';
import 'book_service.dart';
import 'videoElement.dart';
import 'audioElement.dart';
import '3dModel.dart';

class BookEditorScreen extends StatefulWidget {
  const BookEditorScreen({super.key});

  @override
  State<BookEditorScreen> createState() => _BookEditorScreenState();
}

class _BookEditorScreenState extends State<BookEditorScreen> {
  final _htmlController = TextEditingController();
  final _cssController = TextEditingController();
  final _service = BookService();

  PageModel? _pageModel;
  bool _loading = false;

  Future<void> _renderBook() async {
    setState(() => _loading = true);
    log("message");
    try {
      final model = await _service.parseHtmlCss(
        html: _htmlController.text,
        css: _cssController.text,
      );

      setState(() => _pageModel = model);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to render book')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML → Flutter Book Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.amber),
            onPressed: _renderBook,
          ),
        ],
      ),
      body: _buildPreview(),
    );
  }

  Widget _buildPreview() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pageModel == null) {
      return const Center(child: Text('No preview'));
    }

    final page = _pageModel!.book.pages.first;
    final elements = page.layers.first.elements;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: page.size.width),
          child: Container(
            width: page.size.width,
            color: _cssColor(page.background),
            child: Column(
              // 🔥 NOT STACK
              crossAxisAlignment: CrossAxisAlignment.start,
              children: elements.map((e) => _renderRecursive(e)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// The main recursive renderer that fixes the ParentData error
  Widget _renderRecursive(PageElement e, {bool isRoot = false}) {
    Widget child;

    // 1️⃣ FLOW LAYOUT
    if (e.type == ElementType.row || e.type == ElementType.column) {
      final children = e.children.map((c) {
        final childWidget = _renderRecursive(c);

        // 🔥 CRITICAL FIX: Row children must be Flexible
        if (e.type == ElementType.row && c.style.width == null) {
          return Flexible(child: childWidget);
        }

        return childWidget;
      }).toList();

      child = e.type == ElementType.row
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            );
    } else {
      child = _renderLeaf(e);
    }

    // 2️⃣ APPLY PADDING (instead of transform)
    final padding = EdgeInsets.only(
      top: e.style.paddingTop ?? 0,
      left: e.style.paddingLeft ?? 0,
      right: e.style.paddingRight ?? 0,
      bottom: e.style.paddingBottom ?? 0,
    );

    // 3️⃣ CONSTRAIN WIDTH FOR TEXT SAFETY
    Widget boxed = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: e.style.width ?? double.infinity),
      child: Container(
        width: e.style.width,
        decoration: BoxDecoration(
          color: _cssColor(e.style.background),
          // border: Border.all(
          //   color: e.type == ElementType.row
          //       ? Colors.red
          //       : e.type == ElementType.column
          //       ? Colors.amber
          //       : Colors.black,
          // ),
        ),
        child: child,
      ),
    );

    Widget padded = Padding(padding: padding, child: boxed);

    // 4️⃣ FLEX GROW (must wrap container)
    if (!isRoot && e.style.flexGrow != null && e.style.flexGrow! > 0) {
      padded = Expanded(flex: e.style.flexGrow!.toInt(), child: padded);
    }

    // 5️⃣ ABSOLUTE POSITIONING (ONLY HERE)
    if (e.frame != null && isRoot) {
      return Positioned(
        left: e.frame!.x,
        top: e.frame!.y,
        width: e.frame!.width ?? e.style.width,
        height: e.frame!.height ?? e.style.height,
        child: padded,
      );
    }

    return padded;
  }

  Widget _renderLeaf(PageElement e) {
    switch (e.type) {
      case ElementType.text:
        return Text(
          e.data.value ?? '',
          softWrap: true,
          overflow: TextOverflow.visible,
          textAlign: _parseTextAlign(e.style.textAlign),
          style: TextStyle(
            fontFamily: 'Tinos',
            fontSize: e.style.fontSize ?? 17,
            color: _cssColor(e.style.color),
            fontWeight: e.style.fontWeight == 'bold'
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        );

      case ElementType.image:
        return Image.network(e.data.src ?? '', fit: BoxFit.contain);

      case ElementType.video:
        return VideoElement(url: e.data.src ?? '');

      case ElementType.audio:
        return AudioElement(url: e.data.src ?? '');

      case ElementType.model3d:
        return SizedBox(
          height: 400,
          width: 600,
          child: Model3DElement(src: e.data.src ?? ''),
        );

      case ElementType.math:
        return Text(
          e.data.value ?? '',
          style: const TextStyle(fontStyle: FontStyle.italic),
        );

      case ElementType.divider:
        return const Divider();

      default:
        return const SizedBox.shrink();
    }
  }

  TextAlign _parseTextAlign(String? align) {
    if (align == 'justify') return TextAlign.justify;
    if (align == 'center') return TextAlign.center;
    if (align == 'right') return TextAlign.right;
    return TextAlign.left;
  }

  Color _cssColor(String? hex) {
    if (hex == null || hex == 'transparent' || hex.isEmpty)
      return Colors.transparent;
    try {
      // Handle #ffffff or #fff
      String cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 3) {
        cleanHex = cleanHex.split('').map((c) => '$c$c').join();
      }
      return Color(int.parse('0xff$cleanHex'));
    } catch (e) {
      return Colors.black;
    }
  }
}
