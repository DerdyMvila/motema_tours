import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motema Safaris',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showOfflineScreen();
    } else {
      _navigateToHome();
    }
  }

  void _showOfflineScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OfflineScreen(retryCallback: _checkConnectivity),
      ),
    );
  }

  void _navigateToHome() {
    Timer(
      const Duration(seconds: 2),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyWebView(
              initialUrl: 'https://motema-safaris.com/motemaapp/',
              drawerLinks: [
                'https://motema-safaris.com/motemaapp/',
                'https://motema-safaris.com/motemaapp/meet-our-team/',
                'https://motema-safaris.com/motemaapp/faq/',
                'https://motema-safaris.com/motemaapp/testimonial/',
              ],
              bottomNavLinks: [
                'https://motema-safaris.com/motemaapp/',
                'https://motema-safaris.com/motemaapp/about-us/',
                'https://motema-safaris.com/motemaapp/cart-2/',
                'https://motema-safaris.com/motemaapp/contact-us/',
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splash_icon.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Making Memories our Speciality',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineScreen extends StatelessWidget {
  final VoidCallback retryCallback;

  const OfflineScreen({Key? key, required this.retryCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No internet connection',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: retryCallback,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWebView extends StatefulWidget {
  final String initialUrl;
  final List<String> drawerLinks;
  final List<String> bottomNavLinks;

  const MyWebView({
    Key? key,
    required this.initialUrl,
    required this.drawerLinks,
    required this.bottomNavLinks,
  }) : super(key: key);

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late WebViewController _webViewController;
  late bool _canGoBack;
  int _currentIndex = 0; // Define and initialize _currentIndex

  @override
  void initState() {
    super.initState();
    _canGoBack = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_canGoBack) {
          _webViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Motema Safaris', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                _webViewController.reload();
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const UserAccountsDrawerHeader(
                accountName: Text('Motema Safaris', style: TextStyle(color: Colors.white)),
                accountEmail: Text('info@motemasafaris.com', style: TextStyle(color: Colors.white)),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
              ),
              _buildDrawerItem(Icons.home, 'Home', widget.drawerLinks[0]),
              _buildDrawerItem(Icons.people, 'Our Team', widget.drawerLinks[1]),
              _buildDrawerItem(Icons.help, 'FAQ', widget.drawerLinks[2]),
              _buildDrawerItem(Icons.star, 'Testimonial', widget.drawerLinks[3]),
              const Divider(),
              const ListTile(
                title: Text('Follow Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _buildSocialMediaItem('assets/facebook_icon.png', 'Facebook', 'https://www.facebook.com'),
              _buildSocialMediaItem('assets/tiktok_icon.png', 'TikTok', 'https://www.tiktok.com/@motema.tours.safaris'),
              _buildSocialMediaItem('assets/whatsapp_icon.png', 'WhatsApp', 'https://motema-safaris.com/motemaapp/thank-you/'),
              _buildSocialMediaItem('assets/youtube_icon.png', 'YouTube', 'https://www.youtube.com/@motematoursandsafaris2494'),
              _buildSocialMediaItem('assets/instagram_icon.png', 'Instagram', 'https://www.instagram.com/motema.safaris.africa'),
              _buildSocialMediaItem('assets/linkedin_icon.png', 'LinkedIn', 'https://www.linkedin.com/company/motema-tours'),
            ],
          ),
        ),
        body: WebView(
          initialUrl: widget.initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            _webViewController = controller;
            _webViewController.currentUrl().then((url) {
              setState(() {
                _canGoBack = url != widget.initialUrl;
              });
            });
          },
          onPageFinished: (url) {
            setState(() {
              _canGoBack = true;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _loadUrl(widget.bottomNavLinks[index]);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info, color: Colors.black),
              label: 'About Us',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail, color: Colors.black),
              label: 'Contact Us',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String url) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _loadUrl(url);
      },
    );
  }

  Widget _buildSocialMediaItem(String iconPath, String title, String url) {
    return ListTile(
      leading: SizedBox(
        width: 24,
        height: 24,
        child: Image.asset(iconPath, width: 24, height: 24),
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _loadUrl(url);
      },
    );
  }

  void _loadUrl(String url) {
    _webViewController.loadUrl(url);
  }
}
