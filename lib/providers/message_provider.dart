import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Message> _unreadMessages = [];
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  // Getters
  List<Message> get messages => _messages;
  List<Message> get unreadMessages => _unreadMessages;
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  
  MessageProvider() {
    _loadMessages();
  }
  
  // Mesajları SharedPreferences'dan yükle
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('messages') ?? [];
      
      _messages = messagesJson
          .map((json) => Message.fromJson(jsonDecode(json)))
          .toList();
      
      _updateUnreadMessages();
      notifyListeners();
    } catch (e) {
      debugPrint('Mesaj yükleme hatası: $e');
    }
  }
  
  // Mesajları SharedPreferences'a kaydet
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages
          .map((message) => jsonEncode(message.toJson()))
          .toList();
      
      await prefs.setStringList('messages', messagesJson);
    } catch (e) {
      debugPrint('Mesaj kaydetme hatası: $e');
    }
  }
  
  // Yeni mesaj ekle
  void addMessage(Message message) {
    _messages.insert(0, message); // En yeni mesajı başa ekle
    
    // Maksimum 100 mesaj sakla
    if (_messages.length > 100) {
      _messages = _messages.take(100).toList();
    }
    
    _updateUnreadMessages();
    _saveMessages();
    notifyListeners();
  }
  
  // Mesajı okundu olarak işaretle
  void markMessageAsRead(String messageId) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].markAsRead();
      _updateUnreadMessages();
      _saveMessages();
      notifyListeners();
    }
  }
  
  // Tüm mesajları okundu olarak işaretle
  void markAllMessagesAsRead() {
    _messages = _messages.map((msg) => msg.markAsRead()).toList();
    _updateUnreadMessages();
    _saveMessages();
    notifyListeners();
  }
  
  // Okunmamış mesajları güncelle
  void _updateUnreadMessages() {
    _unreadMessages = _messages.where((msg) => !msg.isRead).toList();
  }
  
  // Mesaj türüne göre filtrele
  List<Message> getMessagesByType(MessageType type) {
    return _messages.where((msg) => msg.type == type).toList();
  }
  
  // Gönderen kişiye göre filtrele
  List<Message> getMessagesBySender(String senderId) {
    return _messages.where((msg) => msg.senderId == senderId).toList();
  }
  
  // Acil durum mesajlarını getir
  List<Message> get emergencyMessages {
    return getMessagesByType(MessageType.emergency);
  }
  
  // Ses mesajlarını getir
  List<Message> get voiceMessages {
    return getMessagesByType(MessageType.voice);
  }
  
  // Metin mesajlarını getir
  List<Message> get textMessages {
    return getMessagesByType(MessageType.text);
  }
  
  // Durum mesajlarını getir
  List<Message> get statusMessages {
    return getMessagesByType(MessageType.status);
  }
  
  // Mesaj sayısını getir
  int get messageCount => _messages.length;
  int get unreadCount => _unreadMessages.length;
  int get emergencyCount => emergencyMessages.length;
  
  // Son mesajı getir
  Message? get lastMessage => _messages.isNotEmpty ? _messages.first : null;
  
  // Belirli bir tarihten sonraki mesajları getir
  List<Message> getMessagesAfter(DateTime date) {
    return _messages.where((msg) => msg.timestamp.isAfter(date)).toList();
  }
  
  // Belirli bir tarih aralığındaki mesajları getir
  List<Message> getMessagesBetween(DateTime start, DateTime end) {
    return _messages.where((msg) => 
      msg.timestamp.isAfter(start) && msg.timestamp.isBefore(end)
    ).toList();
  }
  
  // Mesaj ara
  List<Message> searchMessages(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _messages.where((msg) => 
      msg.content.toLowerCase().contains(lowercaseQuery) ||
      msg.senderName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Mesaj sil
  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    _updateUnreadMessages();
    _saveMessages();
    notifyListeners();
  }
  
  // Tüm mesajları sil
  void clearAllMessages() {
    _messages.clear();
    _unreadMessages.clear();
    _saveMessages();
    notifyListeners();
  }
  
  // Ses kaydı başlat
  void startRecording() {
    _isRecording = true;
    _currentRecordingPath = null;
    notifyListeners();
  }
  
  // Ses kaydı durdur
  void stopRecording(String? recordingPath) {
    _isRecording = false;
    _currentRecordingPath = recordingPath;
    notifyListeners();
  }
  
  // Ses kaydını iptal et
  void cancelRecording() {
    _isRecording = false;
    _currentRecordingPath = null;
    notifyListeners();
  }
  
  // Mesaj istatistikleri
  Map<String, int> get messageStatistics {
    Map<String, int> stats = {};
    
    for (MessageType type in MessageType.values) {
      stats[type.toString()] = getMessagesByType(type).length;
    }
    
    return stats;
  }
  
  // En aktif gönderenler
  Map<String, int> get activeSenders {
    Map<String, int> senders = {};
    
    for (Message message in _messages) {
      senders[message.senderName] = (senders[message.senderName] ?? 0) + 1;
    }
    
    return senders;
  }
  
  // Mesajları dışa aktar (JSON)
  String exportMessages() {
    final messagesJson = _messages.map((msg) => msg.toJson()).toList();
    return jsonEncode(messagesJson);
  }
  
  // Mesajları içe aktar (JSON)
  void importMessages(String jsonData) {
    try {
      final List<dynamic> messagesList = jsonDecode(jsonData);
      final importedMessages = messagesList
          .map((json) => Message.fromJson(json))
          .toList();
      
      _messages.addAll(importedMessages);
      _updateUnreadMessages();
      _saveMessages();
      notifyListeners();
    } catch (e) {
      debugPrint('Mesaj içe aktarma hatası: $e');
    }
  }
  
  // Mesajları tarihe göre grupla
  Map<String, List<Message>> getMessagesGroupedByDate() {
    Map<String, List<Message>> grouped = {};
    
    for (Message message in _messages) {
      String dateKey = '${message.timestamp.year}-${message.timestamp.month.toString().padLeft(2, '0')}-${message.timestamp.day.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      
      grouped[dateKey]!.add(message);
    }
    
    return grouped;
  }
} 