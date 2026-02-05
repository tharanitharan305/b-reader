import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models.dart';
class McqWidget extends StatefulWidget {
  final McqItem item;
  Function play;
   McqWidget(this.item, this.play,{super.key});

  @override
  State<McqWidget> createState() => _McqWidgetState();
}

class _McqWidgetState extends State<McqWidget> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.question,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),


          ...widget.item.options.map((opt) {
            return RadioListTile<String>(
              value: opt.id,
              groupValue: selected,
              onChanged: (v) {
                if(v==widget.item.correctAnswerId){
                  widget.play();
                }

                setState(() => selected = v);
              },
              title: Text(opt.text,style: TextStyle(fontSize: 14),),
              dense: true,
              visualDensity: VisualDensity.compact,                              // 🔑 KEY
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }
}
