import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/providers/authprovider.dart';
import 'package:leafy_mobile_app/providers/cartprovider.dart';
import 'package:leafy_mobile_app/providers/postprovider.dart';
import 'package:leafy_mobile_app/providers/products_provider.dart';
import 'package:leafy_mobile_app/screens/homescreen.dart';
import 'package:leafy_mobile_app/screens/landingscreen.dart';
import 'package:leafy_mobile_app/screens/loginscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          useMaterial3: false,
        ),
        home: const LandingScreen(),
      ),
    );
  }
}

class ScreenRouter extends StatefulWidget {
  const ScreenRouter({super.key});

  @override
  State<ScreenRouter> createState() => _ScreenRouterState();
}

class _ScreenRouterState extends State<ScreenRouter> {
  bool haveToken = false;

  checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      setState(() {
        haveToken = true;
      });
    } else {
      setState(() {
        haveToken = false;
      });
    }
  }

  @override
  void initState() {
    checkStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return haveToken ? const HomeScreen() : const LoginScreen();
  }
}
