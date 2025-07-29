import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  final Function(Message) onMessageTap;

  const MessageList({
    super.key,
    required this.messages,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz mesaj yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'İlk mesajı gönderin!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: true, // En yeni mesajlar altta
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          onTap: () => onMessageTap(message),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmergency = message.type == MessageType.emergency;
    final isVoice = message.type == MessageType.voice;
    final isStatus = message.type == MessageType.status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gönderen bilgisi
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(message.typeColor).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.typeIcon,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(message.typeColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  message.formattedTime,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                if (!message.isRead) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Mesaj içeriği
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEmergency 
                    ? Colors.red.withOpacity(0.1)
                    : isVoice
                        ? Colors.green.withOpacity(0.1)
                        : isStatus
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(message.typeColor).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEmergency) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.emergency,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ACİL DURUM!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (isVoice) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.mic,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ses Mesajı',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            // Ses çalma işlemi
                          },
                        ),
                      ],
                    ),
                  ] else if (isStatus) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Durum Güncellemesi',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: isEmergency ? 16 : 14,
                      fontWeight: isEmergency ? FontWeight.w600 : FontWeight.normal,
                      color: isEmergency ? Colors.red.shade800 : Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Pil seviyesi
                  Row(
                    children: [
                      const Icon(
                        Icons.battery_full,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pil: ${message.batteryLevel}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 