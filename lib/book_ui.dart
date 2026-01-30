import 'dart:developer';

import 'package:btab/home/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'models.dart';
import 'book_service.dart';
import 'videoElement.dart';
import 'audioElement.dart';
import '3dModel.dart';

class BookEditorScreen extends StatefulWidget {
  final PageModel pageModel;
  const BookEditorScreen({super.key, required this.pageModel});

  @override
  State<BookEditorScreen> createState() => _BookEditorScreenState();
}

class _BookEditorScreenState extends State<BookEditorScreen> {
  final _service = BookService();
  PageModel? _pageModel;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pageModel = widget.pageModel;
  }

  // Future<void> _renderBook() async {
  //   setState(() => _loading = true);
  //   try {
  //     // In a real app, you might want to fetch based on some criteria
  //     // For now, I'll keep the logic consistent with your render intent
  //     final model = await _service.parseHtmlCss(
  //       html: "", // These might need actual data if you want to re-render from inputs
  //       css: "",
  //     );
  //     setState(() => _pageModel = model);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to render book')),
  //     );
  //   }
  //   setState(() => _loading = false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        cacheExtent: 1000, // Keeps more items in memory to prevent reloading
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
            floating: true,
            snap: true,
            pinned: false,
            title: Text(_pageModel?.bookName ?? "B-Reader"),
            actions: [
              Row(
                children: [
                  IconButton(onPressed: (){}, icon: Icon(Icons.search)),
                  IconButton(onPressed: (){}, icon: Icon(Icons.settings)),
                  IconButton(onPressed: (){}, icon: Icon(Icons.download)),

                ],
              )
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_pageModel == null || _pageModel!.book.pages.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No preview')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _PageItem(
                    page: _pageModel!.book.pages[index],
                    pageNumber: index + 1,
                    renderRecursive: _renderRecursive,
                    cssColor: _cssColor,
                  );
                },
                childCount: _pageModel!.book.pages.length,
                addAutomaticKeepAlives: true, // Crucial for state preservation
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderRecursive(PageElement e, {bool isRoot = false}) {
    Widget child;

    if (e.type == ElementType.row || e.type == ElementType.column) {
      final children = e.children.map((c) {
        final childWidget = _renderRecursive(c);
        if (e.type == ElementType.row &&
            c.style.width == null &&
            (c.style.flexGrow == null || c.style.flexGrow! <= 0)) {
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

    final padding = EdgeInsets.only(
      top: e.style.paddingTop ?? 0,
      left: e.style.paddingLeft ?? 0,
      right: e.style.paddingRight ?? 0,
      bottom: e.style.paddingBottom ?? 0,
    );

    Widget boxed = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: e.style.width ?? double.infinity),
      child: Container(
        width: e.style.width,
        decoration: BoxDecoration(
          color: _cssColor(e.style.background),
        ),
        child: child,
      ),
    );

    Widget padded = Padding(padding: padding, child: boxed);

    if (!isRoot && e.style.flexGrow != null && e.style.flexGrow! > 0) {
      padded = Expanded(flex: e.style.flexGrow!.toInt(), child: padded);
    }

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
        return VideoElement(
          url: e.data.src ?? '',
          height: e.style.height,
          width: e.style.width ?? 700,
        );
      case ElementType.audio:
        return AudioElement(url: e.data.src ?? '');
      case ElementType.model3d:
        return SizedBox(
          height: 300,
          width: 300,
          child: Model3DElement(src: e.data.src ?? ''),
        );
      case ElementType.math:
        return Math.tex(
          e.data.value ?? '',
          textStyle: TextStyle(
            fontSize: e.style.fontSize ?? 18,
            color: _cssColor(e.style.color),
          ),
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
    if (hex == null || hex == 'transparent' || hex.isEmpty) return Colors.transparent;
    try {
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

class _PageItem extends StatefulWidget {
  final PageData page;
  final int pageNumber;
  final Widget Function(PageElement, {bool isRoot}) renderRecursive;
  final Color Function(String?) cssColor;

  const _PageItem({
    required this.page,
    required this.pageNumber,
    required this.renderRecursive,
    required this.cssColor,
  });

  @override
  State<_PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<_PageItem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Prevents the page from being disposed when scrolled off-screen

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final elements = widget.page.layers.isNotEmpty ? widget.page.layers.first.elements : <PageElement>[];

    return Center(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            height: widget.page.size.height,
            width: widget.page.size.width,
            decoration: BoxDecoration(
              color: widget.cssColor(widget.page.background),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: elements.map((e) => widget.renderRecursive(e, isRoot: true)).toList(),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Page ${widget.pageNumber}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
