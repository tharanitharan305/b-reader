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
            icon: const Icon(Icons.play_arrow),
            onPressed: _renderBook,
          ),
        ],
      ),
      body: Row(
        children: [
          // Expanded(child: _buildEditor()),
          // const VerticalDivider(width: 1),
          Expanded(child: _buildPreview()),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        _codeEditor('HTML', _htmlController),
        const Divider(height: 1),
        _codeEditor('CSS', _cssController),
      ],
    );
  }

  Widget _codeEditor(String title, TextEditingController controller) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
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
      child: Container(
        width: page.size.width,
        height: page.size.height,
        color: _cssColor(page.background),
        child: Stack(
          children: elements
              .map((e) => _renderRecursive(e, isRoot: true))
              .toList(),
        ),
      ),
    );
  }

  /// The main recursive renderer that fixes the ParentData error
  Widget _renderRecursive(PageElement e, {bool isRoot = false}) {
    Widget current;

    // 1. Build Content (Layout vs Leaf)
    if (e.type == ElementType.row || e.type == ElementType.column) {
      final children = e.children.map((c) => _renderRecursive(c)).toList();
      current = e.type == ElementType.row
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
    } else {
      current = _renderLeaf(e);
    }

    // 2. Apply Padding and Constraints
    // Note: CSS padding is applied outside the content
    current = Padding(
      padding: EdgeInsets.only(
        top: e.style.paddingTop ?? 0,
        left: e.style.paddingLeft ?? 0,
        right: e.style.paddingRight ?? 0,
        bottom: e.style.paddingBottom ?? 0,
      ),
      child: Container(
        width: e.style.width,
        height: e.style.height,
        decoration: BoxDecoration(color: _cssColor(e.style.background)),
        child: current,
      ),
    );

    // 3. Handle Layout Accuracy (flex-grow)
    // Wrap in Expanded ONLY if inside a Flex (Row/Column) and has flex-grow
    if (!isRoot && e.style.flexGrow != null && e.style.flexGrow! > 0) {
      current = Expanded(flex: e.style.flexGrow!.toInt(), child: current);
    }

    // 4. Handle Positioning Accuracy
    // FIX: Only use Positioned if parent is a Stack (isRoot).
    // Otherwise use Transform to avoid ParentData error while maintaining visual offset.
    if (e.frame != null) {
      if (isRoot) {
        return Positioned(
          left: e.frame!.x,
          top: e.frame!.y,
          width: e.frame!.width,
          height: e.frame!.height,
          child: current,
        );
      } else {
        return Transform.translate(
          offset: Offset(e.frame!.x, e.frame!.y),
          child: current,
        );
      }
    }

    return current;
  }

  Widget _renderLeaf(PageElement e) {
    switch (e.type) {
      case ElementType.text:
        return Text(
          e.data.value ?? '',
          textAlign: _parseTextAlign(e.style.textAlign),
          style: TextStyle(
            fontSize: e.style.fontSize,
            color: _cssColor(e.style.color),
            fontWeight: e.style.fontWeight == 'bold'
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        );

      case ElementType.image:
        return Image.network(
          e.data.src ?? '',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        );

      case ElementType.video:
        return VideoElement(url: e.data.src ?? '');

      case ElementType.audio:
        return AudioElement(url: e.data.src ?? '');

      case ElementType.model3d:
        return Model3DElement(src: e.data.src ?? '');

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
