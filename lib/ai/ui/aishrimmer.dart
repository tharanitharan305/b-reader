import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_bloc.dart';
import '../bloc/ai_event.dart';
import '../bloc/ai_state.dart';
import '../data/ai_model.dart';

import 'package:shimmer/shimmer.dart';
class AiSummaryDialog extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;

  const AiSummaryDialog({
    super.key,
    required this.text,
    required this.style,
    required this.align,
  });

  @override
  State<AiSummaryDialog> createState() => _AiSummaryDialogState();
}

class _AiSummaryDialogState extends State<AiSummaryDialog> {
  LearningType? selectedType;
  final Stopwatch stopwatch = Stopwatch();
  Duration? responseTime;
  Timer? liveTimer;
  Duration liveDuration = Duration.zero;

  void _startRequest(LearningType type) {
    setState(() {
      selectedType = type;
      responseTime = null;
      liveDuration = Duration.zero;
    });

    stopwatch.reset();
    stopwatch.start();

    liveTimer?.cancel();
    liveTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (_) {
        if (mounted) {
          setState(() {
            liveDuration = stopwatch.elapsed;
          });
        }
      },
    );

    final question = QuestionModel(
      learningType: type,
      text: widget.text,
    );

    context.read<SummarizeBloc>().add(SummirizeText(question));
  }

  @override
  void dispose() {
    liveTimer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 520),
        child: Column(
          children: [
            /// 🔥 Timer display
            Text(
              selectedType != null
                  ? "⏱ ${liveDuration.inMilliseconds} ms"
                  : "Select learning mode",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),


            const SizedBox(height: 8),

            /// 🔥 Main content
            Expanded(
              child: selectedType == null
                  ? _buildSelectionView()
                  : BlocListener<SummarizeBloc, SummarizeState>(
                listener: (context, state) {
                  if (state is SummarizeLoaded) {
                    stopwatch.stop();
                    liveTimer?.cancel();

                    setState(() {
                      responseTime = stopwatch.elapsed;
                    });
                  }

                  if (state is SummarizeError) {
                    stopwatch.stop();
                    liveTimer?.cancel();
                  }
                },
                child: BlocBuilder<SummarizeBloc, SummarizeState>(
                  builder: (context, state) {
                    if (state is SummarizeLoading) {
                      return TextShimmer(
                        text: widget.text,
                        style: widget.style,
                        align: widget.align,
                      );
                    }

                    if (state is SummarizeLoaded) {
                      final answer = state.summary;

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              answer.finalSummary.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...answer.finalSummary.paragraphs.map(
                                  (p) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 10),
                                child: Text(p),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is SummarizeError) {
                      return Center(
                        child: Text(
                          "Error: ${state.error}",
                          style: const TextStyle(
                              color: Colors.red),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),


            const SizedBox(height: 12),

            /// 🔥 Exit button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Exit"),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Enum selection UI
  Widget _buildSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          textAlign: widget.align,
        ),
        const SizedBox(height: 20),
        const Text(
          "Choose learning type:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          children: LearningType.values.map((type) {
            return ElevatedButton(
              onPressed: () => _startRequest(type),
              child: Text(type.name.toUpperCase()),
            );
          }).toList(),
        ),
      ],
    );
  }
}


class AiShimmer extends StatelessWidget {
  const AiShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          6,
              (i) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 14,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
class TextShimmer extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;

  const TextShimmer({
    super.key,
    required this.text,
    required this.style,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black,
      highlightColor: Colors.black.withOpacity(0.2),
      child: Text(
        text,
        softWrap: true,
        textAlign: align,
        style: style.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
