import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const KapiKontrolApp());
}

class KapiKontrolApp extends StatelessWidget {
  const KapiKontrolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kapı Kontrol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const KapiKontrolHomePage(),
    );
  }
}

class KapiKontrolHomePage extends StatefulWidget {
  const KapiKontrolHomePage({super.key});

  @override
  State<KapiKontrolHomePage> createState() => _KapiKontrolHomePageState();
}

class _KapiKontrolHomePageState extends State<KapiKontrolHomePage> with SingleTickerProviderStateMixin {
  String _sonuc = '';
  bool _isLoading = false;
  final String espIp = '192.168.10.20';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> kapiyiAcKapat() async {
    setState(() {
      _isLoading = true;
      _sonuc = 'İstek gönderiliyor...';
    });

    try {
      final url = Uri.parse('http://$espIp/toggle?no=3');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          _sonuc = 'İşlem başarılı!';
        });
      } else {
        setState(() {
          _sonuc = 'Hata: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _sonuc = 'Bağlantı hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapı Kontrol'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.door_front_door,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      _animationController.forward().then((_) {
                        _animationController.reverse();
                        kapiyiAcKapat();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kapıyı Aç / Kapat',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _sonuc,
                    style: TextStyle(
                      fontSize: 16,
                      color: _sonuc.contains('Hata')
                          ? Colors.red
                          : _sonuc.contains('başarılı')
                              ? Colors.green
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
