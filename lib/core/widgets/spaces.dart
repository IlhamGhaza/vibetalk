import 'package:flutter/material.dart';

class SpacesHeight extends StatelessWidget {
  final double height;
  const SpacesHeight({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class SpacesWidth extends StatelessWidget {
  final double width;
  const SpacesWidth({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
