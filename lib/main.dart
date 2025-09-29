import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Babylon WebView',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2DD4BF)),
        useMaterial3: true,
      ),
      home: const BabylonWebViewPage(),
    );
  }
}

class BabylonWebViewPage extends StatefulWidget {
  const BabylonWebViewPage({super.key});

  @override
  State<BabylonWebViewPage> createState() => _BabylonWebViewPageState();
}

class _BabylonWebViewPageState extends State<BabylonWebViewPage> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  String? _lastError;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _lastError = null;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _lastError = error.description;
            });
          },
        ),
      )
      ..loadFlutterAsset('assets/babylon/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Babylon.js inside Flutter'),
        actions: [
          IconButton(
            tooltip: 'Reload scene',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingProgress < 100)
            LinearProgressIndicator(value: _loadingProgress / 100),
          if (_lastError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to load Babylon scene.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastError!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _lastError = null;
                              _loadingProgress = 0;
                            });
                            _controller.reload();
                          },
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
