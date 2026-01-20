import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Model3DElement extends StatelessWidget {
  final String src;

  const Model3DElement({super.key, required this.src});

  @override
  Widget build(BuildContext context) {
    log(
      "Modelling --------------------------------------------------------------",
    );
    return ModelViewer(
      src: src,
      alt: "3D model",
      autoRotate: true,
      cameraControls: true,
      disableZoom: false,
      ar: false,
      backgroundColor: Colors.black,
      shadowIntensity: 1,
    );
  }
}
