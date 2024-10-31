import 'package:flutter/material.dart';

class WhiteContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;
  final double? maxHeight;

  const WhiteContainer({
    super.key,
    required this.child,
    this.padding,
    this.minHeight,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0.0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: child,
    );
  }
}
