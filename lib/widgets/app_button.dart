import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final ButtonStyle? style;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon),
      onPressed: loading ? null : onPressed,
      label: Text(label),
      style: style,
    );
  }
}
