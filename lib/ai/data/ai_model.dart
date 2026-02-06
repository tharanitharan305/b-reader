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
    // ✅ Case 1: OLD format
    if (json['content_flow'] != null) {
      final contentFlow = json['content_flow'] as List;

      return FinalSummary(
        title: json['title'] ?? '',
        paragraphs:
        contentFlow.map((e) => e['paragraph'] as String).toList(),
      );
    }

    // ✅ Case 2: EVENTS format
    if (json['events'] != null) {
      return FinalSummary(
        title: json['header'] ?? '',
        paragraphs: List<String>.from(json['events']),
      );
    }

    // ✅ Case 3: RAW fallback
    if (json['raw_content'] != null) {
      return FinalSummary(
        title: "AI Summary",
        paragraphs: [json['raw_content']],
      );
    }

    // ✅ Case 4: ADVANCED STRUCTURE (🔥 YOUR NEW FORMAT)
    if (json['heading'] != null ||
        json['introduction'] != null ||
        json['analytical_details'] != null) {
      List<String> paragraphs = [];

      // Introduction
      if (json['introduction'] != null) {
        paragraphs.add(json['introduction']);
      }

      // Analytical sections
      if (json['analytical_details'] != null) {
        for (var item in json['analytical_details']) {
          paragraphs.add(
              "${item['title']}\n${item['content']}");
        }
      }

      // Conclusion
      if (json['conclusion'] != null) {
        paragraphs.add(json['conclusion']);
      }

      // Ending quote
      if (json['required_ending'] != null) {
        paragraphs.add(json['required_ending']);
      }

      return FinalSummary(
        title: json['heading'] ?? 'AI Summary',
        paragraphs: paragraphs,
      );
    }

    // ❌ fallback
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
