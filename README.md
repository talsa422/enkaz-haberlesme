# Enkaz Altı Bluetooth Haberleşme Sistemi

Deprem sonrası enkaz altında kalan insanlar için ESP32 Bluetooth mesh tabanlı haberleşme sistemi.

## 📱 Hızlı Başlangıç

### **APK İndirme (En Kolay Yöntem)**
1. **Releases** sekmesinden en son APK'yı indirin
2. **Telefona yükleyin** (Bilinmeyen kaynakları açın)
3. **İzinleri verin** ve kullanmaya başlayın

### **GitHub Actions ile Otomatik Build**
- Her commit'te otomatik APK oluşturulur
- **Actions** sekmesinden APK'yı indirebilirsiniz

## Özellikler

- **7 kişilik Bluetooth mesh ağı** - Tüm cihazlar birbirine bağlı
- **Mesaj gönderme/alma** - Metin mesajları
- **Ses iletişimi** - Kısa ses kayıtları
- **Uzun pil ömrü** - ESP32'nin düşük güç modu
- **Şebeke bağımsız** - Kendi Bluetooth ağında çalışır
- **3+1 ev kapsamı** - Bluetooth mesafesi yeterli
- **Kolay kullanım** - 3 buton ile kontrol

## Donanım Gereksinimleri (Her Cihaz İçin)

- **ESP32 DevKit** (ana kart)
- **OLED Ekran** (128x64, I2C)
- **3x Buton** (gönder, menü, ses)
- **Mikrofon** (KY-038 veya dahili)
- **Hoparlör** (8Ω, 0.5W)
- **3.7V Li-ion Pil** (18650)
- **Pil şarj modülü** (TP4056)
- **Kasa** (3D baskı veya hazır)

## Toplam Maliyet (7 Cihaz)

- ESP32: 7 x 80 TL = 560 TL
- OLED: 7 x 30 TL = 210 TL
- Diğer: 7 x 50 TL = 350 TL
- **Toplam: ~1120 TL**

## Kurulum

### **APK ile (Önerilen)**
1. APK'yı indirin
2. Telefona yükleyin
3. İzinleri verin
4. Test edin

### **Kaynak Koddan**
1. Arduino IDE'yi yükleyin
2. ESP32 board paketini ekleyin
3. Gerekli kütüphaneleri yükleyin
4. Kodu yükleyin
5. Test edin

## Kullanım

- **Mesaj gönderme**: MENU → Mesaj → Yaz → GÖNDER
- **Ses kaydı**: SES butonuna basıp konuşun
- **Mesajları dinle**: Gelen mesajlar otomatik görüntülenir
- **Sesleri dinle**: Gelen sesler otomatik çalar

## Bluetooth Mesh Avantajları

✅ **Otomatik bağlantı** - Cihazlar birbirini bulur  
✅ **Mesh ağı** - Her cihaz diğerlerine ulaşabilir  
✅ **Güvenilir** - Bir cihaz bozulsa diğerleri çalışır  
✅ **Kolay kurulum** - Sadece açın ve çalışır  
✅ **Düşük güç** - Uzun pil ömrü  

## Pil Ömrü

- **Bekleme modu**: 7+ gün
- **Aktif kullanım**: 12+ saat
- **Şarj süresi**: 2-3 saat

## Güvenlik

- Bluetooth şifreleme aktif
- Sadece aynı mesh ağındaki cihazlar iletişim kurar
- Acil durum sinyali öncelikli

## Test Senaryoları

### **7 Kişilik Test:**
1. 7 telefonu hazırlayın
2. Hepsinin Bluetooth'unu açın
3. Uygulamayı başlatın
4. Bağlantıları kontrol edin
5. Test mesajı gönderin
6. Ses kaydı yapın
7. Acil durum sinyalini test edin

## Destek

Sorun yaşarsanız:
1. Issues sekmesinden bildirin
2. Detaylı hata mesajı ekleyin
3. Telefon modelini belirtin

## Lisans

Bu proje MIT lisansı altında yayınlanmıştır.

---

**Bu uygulama deprem sonrası enkaz altında kalan insanlar için hayat kurtarıcı bir iletişim aracıdır.** 