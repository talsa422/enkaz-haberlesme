import 'package:flutter/material.dart';

class SendMessageWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const SendMessageWidget({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  widget.onSend(text);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () {
                if (widget.controller.text.isNotEmpty) {
                  widget.onSend(widget.controller.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 