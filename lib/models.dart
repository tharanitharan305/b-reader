import 'dart:developer';

// Although these imports were in your original code,
// this model is pure Dart and technically doesn't require Flutter dependencies
// unless you plan to add UI-specific types later.
// keeping them to ensure compatibility with your environment.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BbookModel {
  final String bookName;
  final String version;
  final BookModel book;

  BbookModel({
    required this.version,
    required this.book,
    required this.bookName
  });

  factory BbookModel.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return BbookModel(
        version: json['version'] ?? "1.0.0",
        book: BookModel.fromList(json['pages'] ?? []),
        bookName: json["title"] ?? "Untitled"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'title': bookName, // Fixed: Maps bookName back to 'title'
      'pages': book.pages.map((p) => p.toJson()).toList(),
    };
  }
}

class BookModel {
  final List<PageData> pages;

  BookModel({required this.pages});

  factory BookModel.fromList(List<dynamic> list) {
    return BookModel(
      // FIXED: Safely cast incoming map to Map<String, dynamic>
      pages: list.map((e) => PageData.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }
}

class PageData {
  final String id;
  final PageSize size;
  final String background;
  final List<PageLayer> layers;

  PageData({
    required this.id,
    required this.size,
    required this.background,
    required this.layers,
  });

  factory PageData.fromJson(Map<String, dynamic> json) {
    return PageData(
      id: json['id'],
      // FIXED: Safely cast nested objects
      size: PageSize.fromJson(Map<String, dynamic>.from(json['size'] ?? {'width': 0, 'height': 0})),
      background: json['background'] ?? '#FFFFFF',
      layers: (json['layers'] as List? ?? [])
      // FIXED: Safely cast list elements
          .map((e) => PageLayer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size.toJson(),
      'background': background,
      'layers': layers.map((l) => l.toJson()).toList(),
    };
  }
}

class PageLayer {
  final String name;
  final List<PageElement> elements;

  PageLayer({required this.name, required this.elements});

  factory PageLayer.fromJson(Map<String, dynamic> json) {
    return PageLayer(
      name: json['name'] ?? 'Layer',
      elements: (json['elements'] as List? ?? [])
      // FIXED: Safely cast list elements
          .map((e) => PageElement.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}

class PageSize {
  final double width;
  final double height;

  PageSize({required this.width, required this.height});

  factory PageSize.fromJson(Map<String, dynamic> json) {
    return PageSize(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

class PageElement {
  final String? id;
  final ElementType type;
  final Frame? frame;
  final ElementStyle style;
  final ElementData data;
  final List<PageElement> children;

  // Holds 2D grid of table cells if type is table/grid
  final List<List<PageElement>>? rows;

  PageElement({
    this.id,
    required this.type,
    this.frame,
    required this.style,
    required this.data,
    required this.children,
    this.rows,
  });

  factory PageElement.fromJson(Map<String, dynamic> json) {
    return PageElement(
      id: json['id'],
      type: ElementTypeX.fromString(json['type']),
      // FIXED: Safely cast nested objects
      frame: json['frame'] != null ? Frame.fromJson(Map<String, dynamic>.from(json['frame'])) : null,
      style: ElementStyle.fromJson(Map<String, dynamic>.from(json['style'] ?? {})),
      data: ElementData.fromJson(Map<String, dynamic>.from(json['data'] ?? {})),
      children: (json['children'] as List? ?? [])
      // FIXED: Safely cast list elements
          .map((e) => PageElement.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),

      // Logic to parse 2D array: rows -> list of lists of cells
      rows: (json['rows'] as List?)?.map((rowJson) {
        return (rowJson as List).map((cellJson) {
          // FIXED: Safely cast cell objects
          return PageElement.fromJson(Map<String, dynamic>.from(cellJson as Map));
        }).toList();
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'type': type.name, // Ensure enum name matches JSON string expectation
      'frame': frame?.toJson(),
      'style': style.toJson(),
      'data': data.toJson(),
      'children': children.map((c) => c.toJson()).toList(),
    };

    // Only add rows if it exists to keep JSON clean
    if (rows != null) {
      json['rows'] = rows!.map((row) => row.map((cell) => cell.toJson()).toList()).toList();
    }

    return json;
  }
}

enum ElementType {
  row,
  column,
  divider,
  text,
  image,
  video,
  audio,
  math,
  model3d,
  table,
  qa,
  spl
}

extension ElementTypeX on ElementType {
  static ElementType fromString(String? value) {
    return ElementType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ElementType.column,
    );
  }
}

class Frame {
  final double x;
  final double y;
  final double? width;
  final double? height;

  Frame({required this.x, required this.y, this.width, this.height});

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}

class ElementStyle {
  final double? fontSize;
  final String? color;
  final String? background;
  final double? width;
  final double? height;
  final double? paddingTop;
  final double? top;
  final double? left;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final double? flexGrow;
  final double? flexShrink;
  final String? flexBasis;
  final String? textAlign;
  final String? fontWeight;
  final String? alignItem;
  final String? position;
  final String? fontFamily;

  ElementStyle({
    this.fontSize,
    this.color,
    this.background,
    this.width,
    this.height,
    this.paddingTop,
    this.paddingLeft,
    this.paddingRight,
    this.paddingBottom,
    this.flexGrow,
    this.textAlign,
    this.fontWeight,
    this.flexShrink,
    this.flexBasis,
    this.top,
    this.left,
    this.alignItem,
    this.position,
    this.fontFamily
  });

  factory ElementStyle.fromJson(Map<String, dynamic> json) {
    final padding = _toDouble(json['padding']);
    return ElementStyle(
        fontSize: _toDouble(json['fontSize'] ?? "14"),
        color: json['color'],
        background: json['background'],
        width: _toDouble(json['width']),
        height: _toDouble(json['height']),
        paddingTop: _toDouble(json['padding-top']) ?? padding,
        paddingLeft: _toDouble(json['padding-left']) ?? padding,
        paddingRight: _toDouble(json['padding-right']) ?? padding,
        paddingBottom: _toDouble(json['padding-bottom']) ?? padding,
        flexGrow: _toDouble(json['flex-grow']),
        flexShrink: _toDouble(json['flex-shrink']),
        flexBasis: json['flex-basis'],
        textAlign: json['textAlign'],
        fontWeight: json['font-weight'],
        left: _toDouble(json['left']),
        top: _toDouble(json['top']),
        alignItem: json['align-items'],
        position: json['position'],
        fontFamily: json['font-family'] ?? "Tinos"
    );
  }

  Map<String, dynamic> toJson() {
    // We filter out nulls only if your API requires strict cleanliness,
    // otherwise returning nulls is fine.
    // This implementation returns all keys matching the specific names from fromJson.
    return {
      'fontSize': fontSize,
      'color': color,
      'background': background,
      'width': width,
      'height': height,
      'padding-top': paddingTop,
      'padding-left': paddingLeft,
      'padding-right': paddingRight,
      'padding-bottom': paddingBottom,
      'flex-grow': flexGrow,
      'flex-shrink': flexShrink,
      'flex-basis': flexBasis,
      'textAlign': textAlign,
      'font-weight': fontWeight,
      'left': left,
      'top': top,
      'align-items': alignItem, // Mapped back to kebab-case
      'position': position,
      'font-family': fontFamily, // Mapped back to kebab-case
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll('px', ''));
    return null;
  }
}

class ElementData {
  final String? value;
  final String? src;
  final List<QaItem>? questions;
  final String? title;
  final List<String>? points;

  ElementData({
    this.value,
    this.src,
    this.questions,
    this.title,
    this.points
  });

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
      value: json['value'],
      src: json['src'],
      questions: (json['questions'] as List?)
      // FIXED: Safely cast list elements
          ?.map((q) => QaItem.fromJson(Map<String, dynamic>.from(q as Map)))
          .toList(),
      title: json['title'],
      points: (json['points'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'src': src,
      'questions': questions?.map((q) => q.toJson()).toList(),
      'title': title,
      'points': points,
    };
  }
}

// ---------------------- QA Models ----------------------

enum QaItemType { mcq, fill, divider }

abstract class QaItem {
  QaItemType get type;

  Map<String, dynamic> toJson();

  factory QaItem.fromJson(Map<String, dynamic> json) {
    // Helper check to handle inconsistent JSON structure
    // where some items use 'type' and others 'questionType'
    if (json['type'] == 'divider') {
      return QaDividerItem();
    }

    switch (json['questionType']) {
      case 'mcq':
        return McqItem.fromJson(json);
      case 'fill':
        return FillItem.fromJson(json);
      default:
      // Fallback or throw, depending on strictness
        throw Exception('Unknown QA item: $json');
    }
  }
}

class McqItem implements QaItem {
  @override
  final QaItemType type = QaItemType.mcq;

  final String question;
  final List<McqOption> options;
  final String? correctAnswerId;

  McqItem({
    required this.question,
    required this.options,
    this.correctAnswerId,
  });

  factory McqItem.fromJson(Map<String, dynamic> json) {
    return McqItem(
      question: json['question'],
      correctAnswerId: json['answer'],
      options: (json['options'] as List)
      // FIXED: Safely cast list elements
          .map((o) => McqOption.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'questionType': 'mcq',
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'answer': correctAnswerId,
    };
  }
}

class McqOption {
  final String id;
  final String text;
  final bool isCorrect;

  McqOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory McqOption.fromJson(Map<String, dynamic> json) {
    return McqOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

enum FillSegmentType { text, blank }

abstract class FillSegment {
  FillSegmentType get type;

  Map<String, dynamic> toJson();

  factory FillSegment.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'text':
        return FillTextSegment(json['value']);
      case 'blank':
        return FillBlankSegment(json['id']);
      default:
        throw Exception('Unknown segment type: ${json['type']}');
    }
  }
}

class FillTextSegment implements FillSegment {
  @override
  final FillSegmentType type = FillSegmentType.text;

  final String value;

  FillTextSegment(this.value);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'value': value,
    };
  }
}

class FillBlankSegment implements FillSegment {
  @override
  final FillSegmentType type = FillSegmentType.blank;

  final String id;

  FillBlankSegment(this.id);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'blank',
      'id': id,
    };
  }
}

class FillItem implements QaItem {
  @override
  final QaItemType type = QaItemType.fill;

  final List<FillSegment> segments;
  final String answer;

  FillItem({
    required this.segments,
    required this.answer,
  });

  factory FillItem.fromJson(Map<String, dynamic> json) {
    return FillItem(
      answer: json['answer'],
      segments: (json['segments'] as List)
      // FIXED: Safely cast list elements
          .map((s) => FillSegment.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'questionType': 'fill',
      'segments': segments.map((s) => s.toJson()).toList(),
      'answer': answer,
    };
  }
}

class QaDividerItem implements QaItem {
  @override
  final QaItemType type = QaItemType.divider;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'divider',
    };
  }
}