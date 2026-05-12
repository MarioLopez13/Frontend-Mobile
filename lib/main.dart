import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartpayut_mobile/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es');

  runApp(
    const ProviderScope(
      child: SmartPayUtApp(),
    ),
  );
}