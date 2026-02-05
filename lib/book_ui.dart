import 'dart:developer';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:btab/ai/data/ai_model.dart';
import 'package:btab/ai/ui/ai_button.dart';
import 'package:btab/home/bloc/home_bloc.dart';
import 'package:btab/home/ui/home.dart';
import 'package:btab/splWidget.dart';
import 'package:btab/widgets/qaWidget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_magnifier/flutter_magnifier.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dataTable.dart';
import 'download_engine/bloc/download_bloc.dart';
import 'models.dart';
import 'book_service.dart';
import 'videoElement.dart';
import 'audioElement.dart';
import '3dModel.dart';
// Ensuring import is present

class BookEditorScreen extends StatefulWidget {
  final BbookModel pageModel;
  const BookEditorScreen({super.key, required this.pageModel});

  @override
  State<BookEditorScreen> createState() => _BookEditorScreenState();
}

ConfettiController _leftController = ConfettiController(duration: const Duration(seconds: 1));
ConfettiController _rightController = ConfettiController(duration: const Duration(seconds: 1));

void play() {
  _leftController.play();
  _rightController.play();
}

class _BookEditorScreenState extends State<BookEditorScreen> {
  final _service = BookService();
  BbookModel? _pageModel;
  bool _loading = false;
  double _flowY = 0;

  @override
  void initState() {
    super.initState();
    _pageModel = widget.pageModel;
  }

  bool _showMagnifier = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          /// MAIN SCROLLABLE CONTENT
          CustomScrollView(
            cacheExtent: 1000,
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                floating: true,
                snap: true,
                pinned: false,
                title: Text(_pageModel?.bookName ?? "B-Reader"),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showMagnifier = !_showMagnifier;
                      });
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
                  IconButton(
                    onPressed: () {
                      context.read<DownloadBloc>().add(StartDownloadEvent(_pageModel!));
                    },
                    icon: const Icon(Icons.download),
                  ),
                  AiIconButton(
                    questionModel: QuestionModel(
                        learningType: LearningType.slow,
                        text:
                        "Herman woke up alarmed by rhythmic footsteps around the table upstairs. He heard the sounds from the bathroom and thought a burglar was inside. His mother, startled by slamming doors, also believed burglars were present.She threw a shoe through a window to alert their neighbor, Bodwell. Bodwell called the police, but it was a mistake. The police broke the door down but found no sign of a burglar, even though they heard creaking in the attic.Herman's grandfather misunderstood the situation. He thought deserters were attacking and violently fought a policeman. A gun accidentally went off during the struggle."),
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
                    addAutomaticKeepAlives: true,
                  ),
                ),
            ],
          ),

          /// CONFETTI OVERLAY (Fixed to Screen Bottom)
          // Confetti: Bottom LEFT
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _leftController,
              blastDirection: -pi / 3, // ~60 degrees Up-Right
              emissionFrequency: 0.1, // Heavier burst
              numberOfParticles: 20,
              minBlastForce: 400, // Minimum force increased
              maxBlastForce: 500,// More particles
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              gravity: 0.3, // Slightly higher gravity for realism
            ),
          ),

          // Confetti: Bottom RIGHT
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _rightController,
              blastDirection: -2 * pi / 3, // ~120 degrees Up-Left
              emissionFrequency: 0.1,
              numberOfParticles: 20,
              minBlastForce: 400, // Minimum force increased
              maxBlastForce: 500, // Maximum force increased to reach top
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              gravity: 0.3,
            ),
          ),

          /// 🔍 MAGNIFIER OVERLAY
          if (_showMagnifier)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              left: 0,
              right: 0,
              child: IgnorePointer(
                // important
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ClipRect(
                    child: Magnifier(
                      size: Size(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height * 0.25,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderRecursive(
      PageElement e, {
        bool isRoot = false,
        bool insideTable = false,
      }) {
    Widget child;

    if (e.type == ElementType.row || e.type == ElementType.column) {
      final normalChildren = <Widget>[];
      final positionedChildren = <Widget>[];

      for (final c in e.children) {
        final childWidget = _renderRecursive(c);

        if (c.style.position == 'absolute' && c.frame != null) {
          final left = (c.style.left ?? 0) + (c.frame?.x ?? 0);
          final top = (c.style.top ?? 0) + (c.frame?.y ?? 0);

          positionedChildren.add(
            Positioned(
              left: left,
              top: top,
              width: c.frame!.width,
              height: c.frame!.height,
              child: childWidget,
            ),
          );
        } else {
          if (e.type == ElementType.row) {
            if (c.style.flexGrow != null && c.style.flexGrow! > 0) {
              normalChildren.add(
                Expanded(
                  flex: c.style.flexGrow!.toInt(),
                  child: childWidget,
                ),
              );
            } else if (c.style.width != null) {
              normalChildren.add(
                SizedBox(
                  width: c.style.width,
                  child: childWidget,
                ),
              );
            } else {
              normalChildren.add(Expanded(child: childWidget));
            }
          } else {
            normalChildren.add(childWidget);
          }
        }
      }

      final flowLayout = e.type == ElementType.row
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: normalChildren,
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: normalChildren,
      );

      child = positionedChildren.isEmpty
          ? flowLayout
          : Stack(
        clipBehavior: Clip.none,
        children: [
          flowLayout,
          ...positionedChildren,
        ],
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
      constraints: BoxConstraints(
        maxWidth: (insideTable && e.type == ElementType.column)
            ? double.infinity
            : e.style.width ?? double.infinity,
      ),
      child: Container(
        width: (insideTable && e.type == ElementType.column) ? null : e.style.width,
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

    // --- FIX STARTS HERE ---
    if (e.frame != null && isRoot) {
      final double finalLeft = (e.style.left ?? 0) + (e.frame?.x ?? 0);
      final double finalTop = (e.style.top ?? 0) + (e.frame?.y ?? 0);

      return Positioned(
        left: finalLeft,
        top: finalTop,
        width: e.frame!.width ?? e.style.width,
        height: e.frame!.height ?? e.style.height,
        child: padded,
      );
    }
    // --- FIX ENDS HERE ---

    if (e.frame != null && (e.frame!.x != 0 || e.frame!.y != 0)) {
      return Transform.translate(
        offset: Offset(e.frame!.x, e.frame!.y),
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
            fontWeight: e.style.fontWeight == 'bold' ? FontWeight.bold : FontWeight.normal,
          ),
        );
      case ElementType.image:
        return Image.network(
          e.data.src ?? '',
          fit: e.style.alignItem == 'stretch' ? BoxFit.cover : BoxFit.contain,
          height: e.style.height,
          width: e.style.width,
        );
      case ElementType.video:
        return VideoElement(
          url: e.data.src ?? '',
          height: e.style.height,
          width: e.style.width ?? 700,
        );
      case ElementType.audio:
        return AudioElement(url: e.data.src ?? '');
      case ElementType.model3d:
        dev.log(e.data.src!);
        return Container(
          width: 300,
            height:300,child: Model3DElement(src: e.data.src!,)); // Placeholder
      case ElementType.math:
        return Math.tex(
          e.data.value ?? '',
          textStyle: TextStyle(
            fontSize: e.style.fontSize ?? 18,
          ),
        );
      case ElementType.divider:
        return const Divider();
      case ElementType.table:
        return BTable(
          element: e,
          renderRecursive: _renderRecursive,
        );
      case ElementType.qa:
        return QaWidget(
          questions: e.data.questions ?? [],
          style: e.style,
          play: play,
        );
      case ElementType.spl:
        return SplWidget(element: e);
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final elements = widget.page.layers.isNotEmpty ? widget.page.layers.first.elements : <PageElement>[];

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            height: widget.page.size.height,
            width: widget.page.size.width,
            decoration: BoxDecoration(
              color: widget.cssColor(widget.page.background),
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

class SizeReporter extends StatefulWidget {
  final Widget child;
  final Function(double height) onSize;

  const SizeReporter({
    required this.child,
    required this.onSize,
    super.key,
  });

  @override
  State<SizeReporter> createState() => _SizeReporterState();
}

class _SizeReporterState extends State<SizeReporter> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null) {
        widget.onSize(size.height);
      }
    });

    return widget.child;
  }
}