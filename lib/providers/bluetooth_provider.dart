import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/message.dart';

class BluetoothProvider with ChangeNotifier {
  static const String _serviceUuid = "12345678-1234-1234-1234-123456789abc";
  static const String _characteristicUuid = "87654321-4321-4321-4321-cba987654321";
  
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _messageCharacteristic;
  
  String _deviceId = '';
  String _deviceName = '';
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isAdvertising = false;
  List<BluetoothDevice> _discoveredDevices = [];
  List<String> _connectedDevices = [];
  int _batteryLevel = 100;
  
  // Stream controllers
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  
  // Getters
  String get deviceId => _deviceId;
  String get deviceName => _deviceName;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isAdvertising => _isAdvertising;
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  List<String> get connectedDevices => _connectedDevices;
  int get batteryLevel => _batteryLevel;
  Stream<Message> get messageStream => _messageController.stream;
  Stream<String> get statusStream => _statusController.stream;
  
  BluetoothProvider() {
    _initializeDevice();
    _setupBluetoothListeners();
  }
  
  Future<void> _initializeDevice() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cihaz ID'sini oluştur veya yükle
    _deviceId = prefs.getString('deviceId') ?? const Uuid().v4();
    _deviceName = prefs.getString('deviceName') ?? 'ENKAZ_${_deviceId.substring(0, 4)}';
    
    // Cihaz bilgilerini kaydet
    await prefs.setString('deviceId', _deviceId);
    await prefs.setString('deviceName', _deviceName);
    
    notifyListeners();
  }
  
  void _setupBluetoothListeners() {
    // Bluetooth durumu değişikliklerini dinle
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      _updateStatus('Bluetooth durumu: ${state.toString()}');
      
      if (state == BluetoothAdapterState.on) {
        _startAdvertising();
        _startScanning();
      }
    });
    
    // Cihaz bulunduğunda
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (!_discoveredDevices.contains(result.device)) {
          _discoveredDevices.add(result.device);
          notifyListeners();
        }
      }
    });
  }
  
  Future<void> _startAdvertising() async {
    try {
      if (_isAdvertising) return;
      
      _isAdvertising = true;
      notifyListeners();
      
      // Advertising data oluştur
      Map<String, dynamic> advertisingData = {
        'deviceId': _deviceId,
        'deviceName': _deviceName,
        'batteryLevel': _batteryLevel,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      String jsonData = jsonEncode(advertisingData);
      List<int> data = utf8.encode(jsonData);
      
      // Advertising başlat
      await FlutterBluePlus.startAdvertising(
        advertisingData: data,
        serviceUuid: _serviceUuid,
      );
      
      _updateStatus('Advertising başlatıldı');
    } catch (e) {
      _updateStatus('Advertising hatası: $e');
      _isAdvertising = false;
      notifyListeners();
    }
  }
  
  Future<void> _startScanning() async {
    try {
      if (_isScanning) return;
      
      _isScanning = true;
      notifyListeners();
      
      // Taramayı başlat
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        allowDuplicates: false,
      );
      
      _updateStatus('Cihaz taraması başlatıldı');
      
      // 10 saniye sonra taramayı durdur
      Timer(const Duration(seconds: 10), () {
        _stopScanning();
      });
    } catch (e) {
      _updateStatus('Tarama hatası: $e');
      _isScanning = false;
      notifyListeners();
    }
  }
  
  Future<void> _stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      notifyListeners();
      
      // Bulunan cihazlara bağlan
      await _connectToDiscoveredDevices();
    } catch (e) {
      _updateStatus('Tarama durdurma hatası: $e');
    }
  }
  
  Future<void> _connectToDiscoveredDevices() async {
    for (BluetoothDevice device in _discoveredDevices) {
      if (!_connectedDevices.contains(device.id.toString())) {
        await _connectToDevice(device);
      }
    }
  }
  
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _updateStatus('${device.name} cihazına bağlanılıyor...');
      
      // Cihaza bağlan
      await device.connect(timeout: const Duration(seconds: 5));
      
      // Servisleri keşfet
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString() == _serviceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == _characteristicUuid) {
              _messageCharacteristic = characteristic;
              
              // Mesaj dinlemeye başla
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((List<int> value) {
                _handleIncomingMessage(value);
              });
              
              _connectedDevices.add(device.id.toString());
              _isConnected = true;
              notifyListeners();
              
              _updateStatus('${device.name} cihazına bağlandı');
              break;
            }
          }
        }
      }
    } catch (e) {
      _updateStatus('Bağlantı hatası: $e');
    }
  }
  
  void _handleIncomingMessage(List<int> data) {
    try {
      String jsonString = utf8.decode(data);
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      Message message = Message.fromJson(jsonData);
      
      // Kendi mesajımı yoksay
      if (message.senderId != _deviceId) {
        _messageController.add(message);
        _updateStatus('Yeni mesaj alındı: ${message.senderName}');
      }
    } catch (e) {
      _updateStatus('Mesaj işleme hatası: $e');
    }
  }
  
  Future<void> sendMessage(Message message) async {
    try {
      if (_messageCharacteristic != null) {
        // Mesajı JSON'a çevir
        Map<String, dynamic> jsonData = message.toJson();
        String jsonString = jsonEncode(jsonData);
        List<int> data = utf8.encode(jsonString);
        
        // Mesajı gönder
        await _messageCharacteristic!.write(data);
        
        _updateStatus('Mesaj gönderildi');
      } else {
        _updateStatus('Bağlı cihaz yok');
      }
    } catch (e) {
      _updateStatus('Mesaj gönderme hatası: $e');
    }
  }
  
  Future<void> sendTextMessage(String content) async {
    Message message = Message(
      senderId: _deviceId,
      senderName: _deviceName,
      content: content,
      type: MessageType.text,
      batteryLevel: _batteryLevel,
    );
    
    await sendMessage(message);
  }
  
  Future<void> sendVoiceMessage(String audioPath) async {
    Message message = Message(
      senderId: _deviceId,
      senderName: _deviceName,
      content: audioPath,
      type: MessageType.voice,
      batteryLevel: _batteryLevel,
    );
    
    await sendMessage(message);
  }
  
  Future<void> sendEmergencySignal() async {
    Message message = Message(
      senderId: _deviceId,
      senderName: _deviceName,
      content: 'ACIL DURUM! YARDIM GEREKİYOR!',
      type: MessageType.emergency,
      batteryLevel: _batteryLevel,
    );
    
    await sendMessage(message);
    _updateStatus('Acil durum sinyali gönderildi');
  }
  
  Future<void> sendStatusUpdate() async {
    Message message = Message(
      senderId: _deviceId,
      senderName: _deviceName,
      content: 'Durum: İyi, Pil: $_batteryLevel%',
      type: MessageType.status,
      batteryLevel: _batteryLevel,
    );
    
    await sendMessage(message);
  }
  
  void _updateStatus(String status) {
    _statusController.add(status);
    debugPrint('Bluetooth Status: $status');
  }
  
  Future<void> updateBatteryLevel(int level) async {
    _batteryLevel = level;
    notifyListeners();
    
    // Pil seviyesini kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('batteryLevel', level);
  }
  
  Future<void> updateDeviceName(String name) async {
    _deviceName = name;
    notifyListeners();
    
    // Cihaz adını kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceName', name);
  }
  
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      
      _isConnected = false;
      _connectedDevices.clear();
      notifyListeners();
      
      _updateStatus('Bağlantı kesildi');
    } catch (e) {
      _updateStatus('Bağlantı kesme hatası: $e');
    }
  }
  
  Future<void> restart() async {
    await disconnect();
    await _startAdvertising();
    await _startScanning();
  }
  
  @override
  void dispose() {
    _messageController.close();
    _statusController.close();
    disconnect();
    super.dispose();
  }
} 