import 'package:btab/ai/data/ai_model.dart';

sealed class SummirizeEvent {}
class SummirizeText extends SummirizeEvent{
  final QuestionModel questionModel;
  SummirizeText(this.questionModel);
}