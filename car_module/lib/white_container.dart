import 'package:flutter/material.dart';

class WhiteContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const WhiteContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: child,
    );
  }
}