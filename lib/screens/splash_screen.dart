import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    
    // 3 saniye sonra ana ekrana geç
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/İkon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bluetooth_searching,
                        size: 60,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Uygulama Adı
                    const Text(
                      'ENKAZ HABERLEŞME',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Alt Başlık
                    const Text(
                      'Bluetooth Mesh İletişim Sistemi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Yükleniyor Animasyonu
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Durum Metni
                    Consumer<BluetoothProvider>(
                      builder: (context, bluetoothProvider, child) {
                        return StreamBuilder<String>(
                          stream: bluetoothProvider.statusStream,
                          builder: (context, snapshot) {
                            String status = 'Sistem başlatılıyor...';
                            
                            if (snapshot.hasData) {
                              status = snapshot.data!;
                            }
                            
                            return Text(
                              status,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Özellikler
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFeature('📱 7 Kişilik Grup İletişimi'),
                          const SizedBox(height: 8),
                          _buildFeature('🔵 Bluetooth Mesh Ağı'),
                          const SizedBox(height: 8),
                          _buildFeature('💬 Mesaj ve Ses İletişimi'),
                          const SizedBox(height: 8),
                          _buildFeature('🚨 Acil Durum Sinyali'),
                          const SizedBox(height: 8),
                          _buildFeature('🔋 Uzun Pil Ömrü'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildFeature(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 