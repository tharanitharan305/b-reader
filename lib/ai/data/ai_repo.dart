

import 'ai_model.dart';
import 'ai_service.dart';

class SummarizeRepository {
  final SummarizeService service;

  SummarizeRepository({required this.service});

  Future<AnswerModel> summarizeText(
      QuestionModel question) async {
    final responseJson =
    await service.summarize(question.toJson());

    return AnswerModel.fromJson(responseJson);
  }
}
