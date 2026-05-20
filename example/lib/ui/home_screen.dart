import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_payments/uni_payments.dart';

import '../data/gateway.dart';
import '../services/payment_demos.dart';
import '../theme/app_theme.dart';
import 'animated_gradient_background.dart';
import 'gateway_tile.dart';
import 'result_card.dart';
import 'sliver_header.dart';

/// Routes a gateway tile tap to the matching `UniPayments.payWith*` call.
///
/// Wallet gateways need the Google Pay JSON config which is loaded once
/// at startup, so they take an extra argument compared with the others.
typedef _GatewayInvoker =
    Future<PaymentResult> Function(
      BuildContext context,
      String googlePayConfig,
    );

final Map<String, _GatewayInvoker> _invokers = <String, _GatewayInvoker>{
  'razorpay': (_, __) => PaymentDemos.razorpay(),
  'stripe': (_, __) => PaymentDemos.stripe(),
  'paystack': (ctx, _) => PaymentDemos.paystack(ctx),
  'paytm': (_, __) => PaymentDemos.paytm(),
  'cashfree': (_, __) => PaymentDemos.cashfree(),
  'phonepe': (_, __) => PaymentDemos.phonepe(),
  'flutterwave': (ctx, _) => PaymentDemos.flutterwave(ctx),
  'paypal': (_, __) => PaymentDemos.paypal(),
  'googlepay': (_, cfg) => PaymentDemos.googlePay(cfg),
  'applepay': (_, cfg) => PaymentDemos.applePay(cfg),
};

/// Demo home screen — a grid of glass tiles, one per payment gateway.
class HomeScreen extends StatefulWidget {
  /// Create the demo home screen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeGatewayId;
  PaymentResult? _lastResult;
  String _googlePayConfig = '';

  @override
  void initState() {
    super.initState();
    _loadGooglePayConfig();
  }

  Future<void> _loadGooglePayConfig() async {
    final cfg = await rootBundle.loadString('assets/json/gpay.json');
    if (!mounted) return;
    setState(() => _googlePayConfig = cfg);
  }

  Future<void> _runGateway(Gateway gateway) async {
    final invoker = _invokers[gateway.id];
    if (invoker == null) return;

    setState(() {
      _activeGatewayId = gateway.id;
      _lastResult = null;
    });

    PaymentResult result;
    try {
      result = await invoker(context, _googlePayConfig);
    } catch (e) {
      result = PaymentFailure(errorCode: 'demo_error', message: e.toString());
    }
    if (!mounted) return;
    setState(() {
      _activeGatewayId = null;
      _lastResult = result;
    });

    // Tactile + audible feedback so failures and cancellations register
    // even when the user isn't looking at the screen.
    switch (result) {
      case PaymentSuccess():
        unawaited(HapticFeedback.lightImpact());
      case PaymentFailure(:final errorCode, :final message):
        unawaited(HapticFeedback.heavyImpact());
        SystemSound.play(SystemSoundType.alert);
        _toast('$errorCode · $message', isError: true);
      case PaymentCancelled():
        unawaited(HapticFeedback.selectionClick());
    }
  }

  void _toast(String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(20),
          backgroundColor: isError
              ? const Color(0xFFEF4444)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          content: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      colors: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SliverHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final g = demoGateways[index];
                    return GatewayTile(
                      gateway: g,
                      loading: _activeGatewayId == g.id,
                      onTap: () => _runGateway(g),
                    );
                  }, childCount: demoGateways.length),
                ),
              ),
              if (_lastResult != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: ResultCard(
                      result: _lastResult!,
                      onDismiss: () => setState(() => _lastResult = null),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: _Footer()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Center(
        child: Text(
          'Demo keys are placeholders — replace before running real charges.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
