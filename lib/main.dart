import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'providers/bluetooth_provider.dart';
import 'providers/message_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // İzinleri iste
  await requestPermissions();
  
  runApp(const EnkazHaberlesmeApp());
}

Future<void> requestPermissions() async {
  // Bluetooth izinleri
  await Permission.bluetooth.request();
  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothAdvertise.request();
  
  // Konum izni (Bluetooth için gerekli)
  await Permission.location.request();
  
  // Mikrofon izni
  await Permission.microphone.request();
  
  // Depolama izni
  await Permission.storage.request();
}

class EnkazHaberlesmeApp extends StatelessWidget {
  const EnkazHaberlesmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'Enkaz Haberleşme',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2196F3),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          textTheme: GoogleFonts.robotoTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
} 