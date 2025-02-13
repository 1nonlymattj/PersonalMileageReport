import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure the correct WebView implementation is set
  if (WebViewPlatform.instance == null) {
    if (WebViewPlatform.instance is! AndroidWebViewPlatform &&
        WebViewPlatform.instance is! WebKitWebViewPlatform) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Mileage Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  final FocusNode _webViewFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController properly
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print("Error loading page: ${error.description}");
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadFlutterAsset(
          'assets/www/index.html'); // ✅ Correct way to load local HTML
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Mileage Report')),
      body: Stack(
        children: [
          Focus(
            // ✅ Ensure WebView does not steal focus
            focusNode: _webViewFocusNode,
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            Center(
                child: CircularProgressIndicator()), // ✅ Show loading spinner
        ],
      ),
    );
  }
}
