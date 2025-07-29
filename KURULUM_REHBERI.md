# Enkaz Haberleşme Uygulaması - Kurulum Rehberi

## 📱 Uygulama Özellikleri

✅ **7 kişilik Bluetooth mesh ağı** - Otomatik bağlantı  
✅ **Mesaj gönderme/alma** - Metin mesajları  
✅ **Ses iletişimi** - Ses kaydı ve gönderme  
✅ **Acil durum sinyali** - Kırmızı buton ile  
✅ **Şebeke bağımsız** - Bluetooth mesh teknolojisi  
✅ **Uzun pil ömrü** - Düşük güç tüketimi  

## 🛠️ Gereksinimler

### Yazılım Gereksinimleri:
- **Flutter SDK** (3.0.0 veya üzeri)
- **Android Studio** veya **VS Code**
- **Git**

### Donanım Gereksinimleri:
- **Android telefon** (Android 5.0+)
- **iPhone** (iOS 12.0+)
- **Bluetooth 4.0+** desteği

## 📋 Kurulum Adımları

### 1. Flutter Kurulumu

```bash
# Flutter SDK'yı indirin
# https://flutter.dev/docs/get-started/install

# Flutter'ı kontrol edin
flutter doctor
```

### 2. Projeyi İndirin

```bash
# Projeyi klonlayın
git clone [proje-url]
cd enkaz_haberlesme

# Bağımlılıkları yükleyin
flutter pub get
```

### 3. Gerekli Kütüphaneler

Aşağıdaki kütüphaneler otomatik olarak yüklenecektir:

```yaml
dependencies:
  flutter_blue_plus: ^1.31.15    # Bluetooth işlemleri
  permission_handler: ^11.3.1    # İzinler
  record: ^5.0.4                 # Ses kaydı
  audioplayers: ^5.2.1           # Ses çalma
  shared_preferences: ^2.2.2     # Veri saklama
  provider: ^6.1.1               # Durum yönetimi
  google_fonts: ^6.1.0           # Fontlar
```

### 4. Android İzinleri

`android/app/src/main/AndroidManifest.xml` dosyasına ekleyin:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />
```

### 5. iOS İzinleri

`ios/Runner/Info.plist` dosyasına ekleyin:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bu uygulama Bluetooth ile diğer cihazlarla iletişim kurmak için kullanılır.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bu uygulama Bluetooth ile diğer cihazlarla iletişim kurmak için kullanılır.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Bu uygulama ses kaydı yapmak için mikrofon erişimi gerektirir.</string>
```

## 🚀 Uygulamayı Çalıştırma

### Geliştirme Modu:

```bash
# Uygulamayı çalıştırın
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

### APK Oluşturma:

```bash
# Android APK oluşturun
flutter build apk --release

# APK dosyası: build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Kullanım

### 1. İlk Kurulum
- Uygulamayı açın
- Bluetooth izinlerini verin
- Konum izinlerini verin
- Mikrofon izinlerini verin

### 2. Cihaz Bağlantısı
- Uygulama otomatik olarak diğer cihazları arar
- Bulunan cihazlara otomatik bağlanır
- Mesh ağı oluşturur

### 3. Mesajlaşma
- **Mesajlar** sekmesinde metin yazın
- **Gönder** butonuna basın
- Mesaj tüm bağlı cihazlara gönderilir

### 4. Ses Kaydı
- **Ses** sekmesine geçin
- **Kaydet** butonuna basın
- Konuşun
- **Durdur** butonuna basın
- Ses otomatik gönderilir

### 5. Acil Durum
- Kırmızı **Acil Durum** butonuna basın
- Tüm cihazlara acil durum sinyali gönderilir
- Sesli uyarı çalar

## 🔧 Sorun Giderme

### Bluetooth Bağlantı Sorunları:

1. **Bluetooth açık değil**
   - Telefon ayarlarından Bluetooth'u açın

2. **Cihaz bulunamıyor**
   - Telefonları birbirine yaklaştırın
   - Bluetooth'u kapatıp açın

3. **Bağlantı kesiliyor**
   - Mesafe çok uzak olabilir
   - Bluetooth gücünü kontrol edin

### Ses Kayıt Sorunları:

1. **Mikrofon izni verilmedi**
   - Ayarlardan mikrofon iznini verin

2. **Ses kaydedilmiyor**
   - Mikrofonun çalıştığından emin olun
   - Uygulamayı yeniden başlatın

### Genel Sorunlar:

1. **Uygulama çöküyor**
   - Telefonu yeniden başlatın
   - Uygulamayı yeniden yükleyin

2. **Mesajlar gelmiyor**
   - Bluetooth bağlantısını kontrol edin
   - Cihazları yeniden başlatın

## 📊 Test Senaryoları

### Test 1: Temel Bağlantı
1. 2 telefonu açın
2. Uygulamayı başlatın
3. Bağlantı durumunu kontrol edin

### Test 2: Mesaj Gönderme
1. Bir telefonda mesaj yazın
2. Gönder butonuna basın
3. Diğer telefonda mesajın geldiğini kontrol edin

### Test 3: Ses Kaydı
1. Ses sekmesine geçin
2. Kayıt yapın
3. Diğer cihazda sesin geldiğini kontrol edin

### Test 4: Acil Durum
1. Acil durum butonuna basın
2. Tüm cihazlarda uyarının geldiğini kontrol edin

## 🔒 Güvenlik

- Bluetooth şifreleme aktif
- Sadece aynı mesh ağındaki cihazlar iletişim kurar
- Kişisel veriler cihazda saklanır
- Şebeke bağlantısı kullanılmaz

## 📞 Destek

Sorun yaşarsanız:
1. Logları kontrol edin
2. Telefonu yeniden başlatın
3. Uygulamayı yeniden yükleyin
4. Bluetooth ayarlarını kontrol edin

## 🎯 Özellikler

- **Otomatik bağlantı** - Cihazlar birbirini bulur
- **Mesh ağı** - Her cihaz diğerlerine ulaşabilir
- **Güvenilir** - Bir cihaz bozulsa diğerleri çalışır
- **Kolay kullanım** - Sadece açın ve çalışır
- **Düşük güç** - Uzun pil ömrü

Bu uygulama deprem sonrası enkaz altında kalan insanlar için hayat kurtarıcı bir iletişim aracıdır. 