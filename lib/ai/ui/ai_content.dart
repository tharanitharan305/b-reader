import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ai_bloc.dart';
import '../bloc/ai_state.dart';

class AiContent extends StatelessWidget {
  const AiContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummarizeBloc, SummarizeState>(
      builder: (context, state) {
        if (state is SummarizeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SummarizeLoaded) {
          final summary = state.summary;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.finalSummary.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.finalSummary.paragraphs.map(
                      (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
              state.error,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const Center(
          child: Text('Tap AI to get summary'),
        );
      },
    );
  }
}
