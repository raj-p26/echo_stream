import 'package:flutter/material.dart';

class LabelledIconButton extends StatelessWidget {
  const LabelledIconButton({
    super.key,
    this.onPressed,
    this.label,
    required this.icon,
    this.color,
  });

  final Icon icon;
  final void Function()? onPressed;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPressed,
          color: color ?? Theme.of(context).colorScheme.primary,
          disabledColor: Theme.of(context).colorScheme.secondary,
          icon: icon,
        ),
        Text(label ?? ''),
      ],
    );
  }
}
