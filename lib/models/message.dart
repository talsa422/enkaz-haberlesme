import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  voice,
  emergency,
  status,
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final int batteryLevel;
  final bool isRead;

  Message({
    String? id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    DateTime? timestamp,
    this.batteryLevel = 100,
    this.isRead = false,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  // JSON'dan Message oluştur
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      timestamp: DateTime.parse(json['timestamp']),
      batteryLevel: json['batteryLevel'] ?? 100,
      isRead: json['isRead'] ?? false,
    );
  }

  // Message'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'batteryLevel': batteryLevel,
      'isRead': isRead,
    };
  }

  // Mesajın kopyasını oluştur
  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    int? batteryLevel,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isRead: isRead ?? this.isRead,
    );
  }

  // Mesajın okundu olarak işaretlenmiş kopyası
  Message markAsRead() {
    return copyWith(isRead: true);
  }

  // Mesaj türüne göre ikon
  String get typeIcon {
    switch (type) {
      case MessageType.text:
        return '💬';
      case MessageType.voice:
        return '🎤';
      case MessageType.emergency:
        return '🚨';
      case MessageType.status:
        return '📊';
    }
  }

  // Mesaj türüne göre renk
  int get typeColor {
    switch (type) {
      case MessageType.text:
        return 0xFF2196F3; // Mavi
      case MessageType.voice:
        return 0xFF4CAF50; // Yeşil
      case MessageType.emergency:
        return 0xFFF44336; // Kırmızı
      case MessageType.status:
        return 0xFFFF9800; // Turuncu
    }
  }

  // Zaman formatı
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'Message(id: $id, sender: $senderName, content: $content, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 