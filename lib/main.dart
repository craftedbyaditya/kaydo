import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/feature_flags/feature_flags_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/fello_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/feature_flags_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Clean paths for kaydo.sayge.in share links (/f/:slug). Hosting must
    // rewrite unknown routes to index.html (see deploy/ and web/_redirects).
    usePathUrlStrategy();
    // Production deployment v1.2.2: Enhanced monitoring and improved error handling
  }

  final config = AppConfig.fromEnvironment();
  try {
    config.validate();
    await configureDependencies(config);
  } catch (e) {
    runApp(_BootErrorApp(message: '$e'));
    return;
  }

  final authBloc = AuthBloc(getIt<AuthRepository>())
    ..add(const AuthSubscriptionRequested());
  final featureFlags = FeatureFlagsController(getIt<FeatureFlagsRepository>());
  // Launch with conservative defaults. A feature-flag RPC must never keep the
  // whole web app on its native splash screen when the network is slow.
  unawaited(featureFlags.refresh());
  runApp(FelloApp(authBloc: authBloc, featureFlags: featureFlags));
}

class _BootErrorApp extends StatelessWidget {
  const _BootErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FelloApp extends StatefulWidget {
  const FelloApp({
    super.key,
    required this.authBloc,
    required this.featureFlags,
  });

  final AuthBloc authBloc;
  final FeatureFlagsController featureFlags;

  @override
  State<FelloApp> createState() => _FelloAppState();
}

class _FelloAppState extends State<FelloApp> with WidgetsBindingObserver {
  late final StreamSubscription _authSubscription;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // A router must be created once for the lifetime of the app. Recreating it
    // during a feature-flag rebuild can discard navigation state.
    _router = createRouter(widget.authBloc, widget.featureFlags);
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = widget.authBloc.stream.listen((_) {
      widget.featureFlags.refresh(force: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.featureFlags.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    widget.featureFlags.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc,
      child: MaterialApp.router(
        title: 'Kaydo',
        debugShowCheckedModeBanner: false,
        theme: FelloTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
