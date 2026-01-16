import 'package:cpuq/services/notification_service.dart';
import 'package:cpuq/services/saved_ticket_service.dart';
import 'package:cpuq/services/supabase_service.dart';
import 'package:cpuq/utils/global_theme.dart';
import 'package:cpuq/view/splash_screen.dart';
import 'package:cpuq/providers/queue_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Notification Service
  await NotificationService().initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: neutralWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSavedTicket();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app returns to foreground, invalidate providers to reconnect
    if (state == AppLifecycleState.resumed) {
      // Invalidate all stream providers to force reconnection
      ref.invalidate(servingTicketsStreamProvider);
      ref.invalidate(waitingTicketsStreamProvider);
      ref.invalidate(departmentsStreamProvider);
    }
  }

  Future<void> _initSavedTicket() async {
    final ticket = await SavedTicketService.getSavedTicketNumber();
    if (ticket != null) {
      ref.read(savedTicketProvider.notifier).state = ticket;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start listening to the global notification provider
    ref.listen(queueNotificationProvider, (_, __) {});

    return MaterialApp(
      title: 'CPU University',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      home: const SplashScreen(),
    );
  }
}
