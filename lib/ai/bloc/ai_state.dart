import 'package:btab/ai/data/ai_model.dart';

sealed class SummarizeState{}
class SummarizeLoading extends SummarizeState{
  final QuestionModel questionModel;
  SummarizeLoading(this.questionModel);
}
class SummarizeLoaded extends SummarizeState{
  final AnswerModel summary;
  SummarizeLoaded(this.summary);
}
class SummarizeError extends SummarizeState{
  final String error;
  SummarizeError(this.error);
}
class InitialSummarizeState extends SummarizeState {}
