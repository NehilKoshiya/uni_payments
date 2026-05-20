import 'package:flutter/material.dart';

import '../data/gateway.dart';
import 'brand_icon.dart';
import 'glass_card.dart';

/// Glass-morphism tile that triggers a payment flow for a given [gateway].
class GatewayTile extends StatelessWidget {
  const GatewayTile({
    super.key,
    required this.gateway,
    required this.onTap,
    this.loading = false,
  });

  final Gateway gateway;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GlassCard(
      tint: gateway.tint,
      onTap: loading ? null : onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _BrandChip(gateway: gateway),
              const Spacer(),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 20,
                  color: onSurface.withValues(alpha: 0.55),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gateway.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                gateway.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gateway.tint.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: BrandIcon(gatewayId: gateway.id, tint: gateway.tint, size: 22),
    );
  }
}
