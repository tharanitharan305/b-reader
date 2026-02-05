import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ai_content.dart';

class AiOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const AiOverlay({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: const [
                  _AiHeader(),
                  SizedBox(height: 12),
                  Expanded(child: AiContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _AiHeader extends StatelessWidget {
  const _AiHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_awesome, color: Colors.deepPurple),
        const SizedBox(width: 8),
        const Text(
          'AI Answer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
