import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btab/ai/data/ai_model.dart';

import '../bloc/ai_bloc.dart';
import '../bloc/ai_event.dart';
import 'ai_overlay.dart';

class AiIconButton extends StatefulWidget {
  final QuestionModel questionModel;

  const AiIconButton({
    super.key,
    required this.questionModel,
  });

  @override
  State<AiIconButton> createState() => _AiIconButtonState();
}

class _AiIconButtonState extends State<AiIconButton> {
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    // 🔥 1. Trigger AI call with given question
    context
        .read<SummarizeBloc>()
        .add(SummirizeText(widget.questionModel));

    // 🔥 2. Show overlay
    _overlayEntry = OverlayEntry(
      builder: (_) => AiOverlay(onClose: _removeOverlay),
    );

    Overlay.of(context, rootOverlay: true)
        .insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.auto_awesome),
      tooltip: 'Ask AI',
      onPressed: _showOverlay,
    );
  }
}
