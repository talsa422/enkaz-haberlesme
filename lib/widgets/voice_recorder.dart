import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/message_provider.dart';
import '../providers/bluetooth_provider.dart';

class VoiceRecorderWidget extends StatefulWidget {
  const VoiceRecorderWidget({super.key});

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }
  
  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
  
  Future<void> _initializeRecorder() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      // İzin iste
    }
  }
  
  Future<void> _startRecording() async {
    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
      );
      
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      
      // Kayıt süresini takip et
      _startRecordingTimer();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başlatılamadı: $e')),
      );
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
      
      // Mesaj provider'ı güncelle
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      messageProvider.stopRecording(path);
      
      // Bluetooth ile gönder
      if (path != null) {
        final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
        bluetoothProvider.sendVoiceMessage(path);
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt durdurulamadı: $e')),
      );
    }
  }
  
  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
        _startRecordingTimer();
      }
    });
  }
  
  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    
    try {
      await _player.play(DeviceFileSource(_recordingPath!));
      
      setState(() {
        _isPlaying = true;
      });
      
      // Oynatma süresini takip et
      _player.onDurationChanged.listen((duration) {
        setState(() {
          _playbackDuration = duration;
        });
      });
      
      _player.onPositionChanged.listen((position) {
        setState(() {
          _playbackPosition = position;
        });
      });
      
      _player.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _playbackPosition = Duration.zero;
        });
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ses çalınamadı: $e')),
      );
    }
  }
  
  Future<void> _stopPlaying() async {
    await _player.stop();
    setState(() {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Kayıt durumu
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isRecording ? Colors.red : Colors.grey,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _isRecording ? Icons.mic : Icons.mic_off,
                  size: 48,
                  color: _isRecording ? Colors.red : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording ? 'Kayıt yapılıyor...' : 'Kayıt hazır',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isRecording ? Colors.red : Colors.grey,
                  ),
                ),
                if (_isRecording) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Kontrol butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Kayıt butonu
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isRecording ? Icons.stop : Icons.mic),
                    const SizedBox(width: 8),
                    Text(_isRecording ? 'Durdur' : 'Kaydet'),
                  ],
                ),
              ),
              
              // Oynat butonu
              if (_recordingPath != null)
                ElevatedButton(
                  onPressed: _isPlaying ? _stopPlaying : _playRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(_isPlaying ? 'Durdur' : 'Oynat'),
                    ],
                  ),
                ),
            ],
          ),
          
          // Oynatma progress bar
          if (_recordingPath != null && _playbackDuration > Duration.zero) ...[
            const SizedBox(height: 20),
            Column(
              children: [
                Slider(
                  value: _playbackPosition.inMilliseconds.toDouble(),
                  max: _playbackDuration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _player.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_playbackPosition)),
                    Text(_formatDuration(_playbackDuration)),
                  ],
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Bilgi metni
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  'Ses kaydınız otomatik olarak diğer cihazlara gönderilecektir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 