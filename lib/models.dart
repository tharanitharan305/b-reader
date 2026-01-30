import 'dart:developer';

class PageModel {
  final String bookName;
  final String version;
  final BookModel book;

  PageModel({required this.version, required this.book,required this.bookName});

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      version: json['version'],
      book: BookModel.fromList(json['pages']),
      bookName: json["title"]
    );
  }

  // ADDED: toJson
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'pages': book.pages.map((p) => p.toJson()).toList(),
    };
  }
}

class BookModel {
  final List<PageData> pages;

  BookModel({required this.pages});

  factory BookModel.fromList(List<dynamic> list) {
    return BookModel(
      pages: list.map((e) => PageData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

// Note: PageModel handles the serialization of the list
// but we can add a helper here if needed.
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
      size: PageSize.fromJson(json['size']),
      background: json['background'],
      layers: (json['layers'] as List)
          .map((e) => PageLayer.fromJson(e))
          .toList(),
    );
  }

  // ADDED: toJson
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
      name: json['name'],
      elements: (json['elements'] as List)
          .map((e) => PageElement.fromJson(e))
          .toList(),
    );
  }

  // ADDED: toJson
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
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  // ADDED: toJson
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

  PageElement({
    this.id,
    required this.type,
    this.frame,
    required this.style,
    required this.data,
    required this.children,
  });

  factory PageElement.fromJson(Map<String, dynamic> json) {
    return PageElement(
      id: json['id'],
      type: ElementTypeX.fromString(json['type']),
      frame: json['frame'] != null ? Frame.fromJson(json['frame']) : null,
      style: ElementStyle.fromJson(json['style'] ?? {}),
      data: ElementData.fromJson(json['data'] ?? {}),
      children: (json['children'] as List? ?? [])
          .map((e) => PageElement.fromJson(e))
          .toList(),
    );
  }

  // ADDED: toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name, // Converts enum to string
      'frame': frame?.toJson(),
      'style': style.toJson(),
      'data': data.toJson(),
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

enum ElementType { row, column, divider, text, image, video, audio, math, model3d }

extension ElementTypeX on ElementType {
  static ElementType fromString(String value) {
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

  // ADDED: toJson
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
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final double? flexGrow;
  final double? flexShrink;
  final String? flexBasis;
  final String? textAlign;
  final String? fontWeight;

  ElementStyle({
    this.fontSize, this.color, this.background, this.width, this.height,
    this.paddingTop, this.paddingLeft, this.paddingRight, this.paddingBottom,
    this.flexGrow, this.textAlign, this.fontWeight, this.flexShrink, this.flexBasis,
  });

  factory ElementStyle.fromJson(Map<String, dynamic> json) {
    return ElementStyle(
      fontSize: _toDouble(json['fontSize']),
      color: json['color'],
      background: json['background'],
      width: _toDouble(json['width']),
      height: _toDouble(json['height']),
      paddingTop: _toDouble(json['padding-top']),
      paddingLeft: _toDouble(json['padding-left']),
      paddingRight: _toDouble(json['padding-right']),
      paddingBottom: _toDouble(json['padding-bottom']),
      flexGrow: _toDouble(json['flex-grow']),
      flexShrink: _toDouble(json['flex-shrink']),
      flexBasis: json['flex-basis'],
      textAlign: json['textAlign'],
      fontWeight: json['font-weight'],
    );
  }

  // ADDED: toJson (maintaining the kebab-case for keys where specified in your fromJson)
  Map<String, dynamic> toJson() {
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

  ElementData({this.value, this.src});

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(value: json['value'], src: json['src']);
  }

  // ADDED: toJson
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'src': src,
    };
  }
}