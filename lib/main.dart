import 'package:app_hotel/pages/autenticacao/auth_page.dart';
import 'package:app_hotel/pages/autenticacao/login_page_auth.dart';
import 'package:app_hotel/pages/cadastrar_imovel/cadastro_imovel_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:app_hotel/firebase_options.dart';
import 'package:app_hotel/pages/home_page/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Captura de erros de inicialização do Firebase
    print('Erro ao inicializar Firebase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            if (authProvider.isAdmin) {
              return const CadastroImovelPage();
            } else {
              return const HomePage();
            }
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
