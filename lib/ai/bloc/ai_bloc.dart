import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btab/ai/data/ai_model.dart';

import '../data/ai_repo.dart';
import 'ai_event.dart';
import 'ai_state.dart';


class SummarizeBloc extends Bloc<SummirizeEvent, SummarizeState> {
  final SummarizeRepository repository;

  SummarizeBloc({required this.repository})
      : super(InitialSummarizeState()) {
    on<SummirizeText>(_onSummarizeText);
  }

  Future<void> _onSummarizeText(
      SummirizeText event,
      Emitter<SummarizeState> emit,
      ) async {
    emit(SummarizeLoading(event.questionModel));

    try {
      final AnswerModel result =
      await repository.summarizeText(event.questionModel);

      emit(SummarizeLoaded(result));
    } catch (e) {
      emit(SummarizeError(e.toString()));
    }
  }
}
