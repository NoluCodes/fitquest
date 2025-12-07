import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final Widget child;

  const LoadingButton({super.key, required this.loading, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0)) : child,
    );
  }
}
