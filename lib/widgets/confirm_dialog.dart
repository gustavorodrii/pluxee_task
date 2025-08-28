import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context,
    {required String title, required String message}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar')),
      ],
    ),
  );
  return res ?? false;
}
