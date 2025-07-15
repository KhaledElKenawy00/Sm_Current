import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sqlite_auth_app/Views/auth.dart';
import 'package:flutter_sqlite_auth_app/provider/stm1_provider.dart';
import 'package:flutter_sqlite_auth_app/provider/stm2_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // FFI initialization for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Set system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final stm1 = STM1Provider();
            stm1.startListening();
            return stm1;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final stm2 = STM2Provider();
            stm2.startListening();
            return stm2;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SM Current',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
