import 'package:flutter/material.dart';
import 'package:uni_payments/uni_payments.dart';

import 'glass_card.dart';

/// Visualises a [PaymentResult] with a coloured status header, error
/// chips, and a copyable raw-response block. Always rendered with a
/// border that matches the outcome so failures are immediately obvious.
class ResultCard extends StatelessWidget {
  /// Create a [ResultCard] for [result].
  const ResultCard({super.key, required this.result, required this.onDismiss});

  /// The result to render.
  final PaymentResult result;

  /// Invoked when the user taps the dismiss icon.
  final VoidCallback onDismiss;

  _Badge get _badge => switch (result) {
    PaymentSuccess() => const _Badge(
      icon: Icons.check_circle_rounded,
      color: Color(0xFF10B981),
      label: 'Payment successful',
    ),
    PaymentFailure() => const _Badge(
      icon: Icons.error_rounded,
      color: Color(0xFFEF4444),
      label: 'Payment failed',
    ),
    PaymentCancelled() => const _Badge(
      icon: Icons.cancel_rounded,
      color: Color(0xFFF59E0B),
      label: 'Payment cancelled',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    final textTheme = Theme.of(context).textTheme;
    final gatewayLabel = result.gatewayName ?? '—';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      tint: badge.color,
      borderColor: badge.color.withValues(alpha: 0.55),
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(badge.icon, color: badge.color, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  badge.label,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _Chip(label: gatewayLabel, color: badge.color),
              IconButton(
                tooltip: 'Dismiss',
                icon: const Icon(Icons.close_rounded),
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ResultBody(result: result, textTheme: textTheme),
        ],
      ),
    );
  }
}

/// Body content varies per result subtype — kept as its own widget so the
/// header layout stays readable.
class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result, required this.textTheme});

  final PaymentResult result;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);
    return switch (result) {
      PaymentSuccess(:final transactionId, :final message) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelledLine(label: 'Transaction id', value: transactionId),
          if (message != null && message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
        ],
      ),
      PaymentFailure(:final errorCode, :final message) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelledLine(label: 'Error code', value: errorCode),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SelectableText(
              message ?? '',
              style: textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
      PaymentCancelled(:final message) => Text(
        message ?? 'User dismissed the payment sheet',
        style: textTheme.bodySmall?.copyWith(color: muted, height: 1.5),
      ),
    };
  }
}

class _LabelledLine extends StatelessWidget {
  const _LabelledLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value.isEmpty ? '—' : value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _Badge {
  const _Badge({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;
}
