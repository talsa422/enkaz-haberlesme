import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/message_provider.dart';
import '../models/message.dart';
import '../widgets/message_list.dart';
import '../widgets/connection_status.dart';
import '../widgets/emergency_button.dart';
import '../widgets/voice_recorder.dart';
import '../widgets/send_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Bluetooth provider'dan gelen mesajları dinle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      
      bluetoothProvider.messageStream.listen((message) {
        messageProvider.addMessage(message);
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enkaz Haberleşme',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Bağlantı durumu
          const ConnectionStatusWidget(),
          
          // Ayarlar butonu
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat),
              text: 'Mesajlar',
            ),
            Tab(
              icon: Icon(Icons.record_voice_over),
              text: 'Ses',
            ),
            Tab(
              icon: Icon(Icons.info),
              text: 'Durum',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Mesajlar Tab
          _buildMessagesTab(),
          
          // Ses Tab
          _buildVoiceTab(),
          
          // Durum Tab
          _buildStatusTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildMessagesTab() {
    return Column(
      children: [
        // Mesaj listesi
        Expanded(
          child: Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              return MessageList(
                messages: messageProvider.messages,
                onMessageTap: (message) {
                  messageProvider.markMessageAsRead(message.id);
                },
              );
            },
          ),
        ),
        
        // Mesaj gönderme alanı
        SendMessageWidget(
          controller: _messageController,
          onSend: (text) {
            if (text.isNotEmpty) {
              final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
              bluetoothProvider.sendTextMessage(text);
              _messageController.clear();
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildVoiceTab() {
    return Column(
      children: [
        // Ses kayıt widget'ı
        const Expanded(
          child: VoiceRecorderWidget(),
        ),
        
        // Ses mesajları listesi
        Expanded(
          child: Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              final voiceMessages = messageProvider.voiceMessages;
              
              if (voiceMessages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz ses mesajı yok',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: voiceMessages.length,
                itemBuilder: (context, index) {
                  final message = voiceMessages[index];
                  return ListTile(
                    leading: const Icon(Icons.mic, color: Colors.green),
                    title: Text(message.senderName),
                    subtitle: Text(message.formattedTime),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        // Ses çalma işlemi
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusTab() {
    return Consumer2<BluetoothProvider, MessageProvider>(
      builder: (context, bluetoothProvider, messageProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cihaz bilgileri
              _buildInfoCard(
                'Cihaz Bilgileri',
                [
                  _buildInfoRow('Cihaz Adı', bluetoothProvider.deviceName),
                  _buildInfoRow('Cihaz ID', bluetoothProvider.deviceId),
                  _buildInfoRow('Pil Seviyesi', '${bluetoothProvider.batteryLevel}%'),
                  _buildInfoRow('Bluetooth Durumu', bluetoothProvider.isConnected ? 'Bağlı' : 'Bağlı Değil'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Bağlantı bilgileri
              _buildInfoCard(
                'Bağlantı Bilgileri',
                [
                  _buildInfoRow('Bağlı Cihazlar', '${bluetoothProvider.connectedDevices.length}'),
                  _buildInfoRow('Tarama Durumu', bluetoothProvider.isScanning ? 'Aktif' : 'Pasif'),
                  _buildInfoRow('Advertising', bluetoothProvider.isAdvertising ? 'Aktif' : 'Pasif'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Mesaj istatistikleri
              _buildInfoCard(
                'Mesaj İstatistikleri',
                [
                  _buildInfoRow('Toplam Mesaj', '${messageProvider.messageCount}'),
                  _buildInfoRow('Okunmamış', '${messageProvider.unreadCount}'),
                  _buildInfoRow('Acil Durum', '${messageProvider.emergencyCount}'),
                  _buildInfoRow('Ses Mesajları', '${messageProvider.voiceMessages.length}'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Hızlı işlemler
              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yenile'),
                    onPressed: () {
                      final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
                      bluetoothProvider.restart();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Durum Gönder'),
                    onPressed: () {
                      final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
                      bluetoothProvider.sendStatusUpdate();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        // Acil durum butonu
        return EmergencyButton(
          onPressed: () {
            final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
            bluetoothProvider.sendEmergencySignal();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Acil durum sinyali gönderildi!'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarlar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Cihaz Adını Değiştir'),
              onTap: () {
                Navigator.pop(context);
                _showDeviceNameDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Tüm Mesajları Sil'),
              onTap: () {
                Navigator.pop(context);
                _showClearMessagesDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
  
  void _showDeviceNameDialog() {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    final controller = TextEditingController(text: bluetoothProvider.deviceName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cihaz Adını Değiştir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Cihaz Adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              bluetoothProvider.updateDeviceName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
  
  void _showClearMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesajları Sil'),
        content: const Text('Tüm mesajlar silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final messageProvider = Provider.of<MessageProvider>(context, listen: false);
              messageProvider.clearAllMessages();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 