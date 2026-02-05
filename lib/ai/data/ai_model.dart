LearningType learningTypeFromJson(String value) {
  return LearningType.values.firstWhere(
        (e) => e.name == value,
    orElse: () => LearningType.average,
  );
}

String learningTypeToJson(LearningType type) {
  return type.name;
}
class QuestionModel {
  final LearningType learningType;
  final String text;

  QuestionModel({
    required this.learningType,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'learner_type': learningTypeToJson(learningType),
    };
  }
}


class AnswerModel {
  final LearningType learningType;
  final String keyIdeas;
  final String neutralSummary;
  final FinalSummary finalSummary;

  AnswerModel({
    required this.learningType,
    required this.keyIdeas,
    required this.neutralSummary,
    required this.finalSummary,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      learningType: learningTypeFromJson(json['learner_type']),
      keyIdeas: json['key_ideas'],
      neutralSummary: json['neutral_summary'],
      finalSummary: FinalSummary.fromJson(json['final_summary']),
    );
  }
}

class FinalSummary {
  final String title;
  final List<String> paragraphs;

  FinalSummary({
    required this.title,
    required this.paragraphs,
  });

  factory FinalSummary.fromJson(Map<String, dynamic> json) {
    // ✅ Case 1: OLD format (content_flow)
    if (json['content_flow'] != null) {
      final contentFlow = json['content_flow'] as List;

      return FinalSummary(
        title: json['title'] ?? '',
        paragraphs: contentFlow
            .map((e) => e['paragraph'] as String)
            .toList(),
      );
    }

    // ✅ Case 2: NEW format (events)
    if (json['events'] != null) {
      return FinalSummary(
        title: json['header'] ?? '',
        paragraphs: List<String>.from(json['events']),
      );
    }

    // ❌ Fallback (never crash)
    return FinalSummary(
      title: '',
      paragraphs: const [],
    );
  }
}



enum LearningType {
  slow,
  average,
  fast,
}
