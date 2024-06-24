import 'package:app_hotel/pages/autenticacao/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_hotel/pages/cores/cores_app.dart';
import 'package:app_hotel/pages/detalhes_imoveis/detalhes_imovels.dart';
import 'package:app_hotel/pages/hotel_page/hotel_page.dart';
import 'package:app_hotel/pages/hotel_page/pousada_page.dart';
import 'tela_card.dart';
import 'package:app_hotel/pages/cadastrar_imovel/cadastro_imovel_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> listaDeLugares = [
    {'nome': 'Hotel 1', 'id': '1'},
    {'nome': 'Pousada 1', 'id': '2'},
    // Adicione mais imóveis conforme necessário
  ];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void mudancaDePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          TelaCardImoveisHome(
            listaDeLugares: listaDeLugares.map((e) => e['nome']!).toList(),
            detalhesImovel: _showPropertyDetails,
          ),
          HotelPage(
            listaDeLugares: listaDeLugares.map((e) => e['nome']!).toList(),
            detalhesImovel: _showPropertyDetails,
          ),
          PousadaPage(
            listaDeLugares: listaDeLugares.map((e) => e['nome']!).toList(),
            detalhesImovel: _showPropertyDetails,
          ),
          if (authProvider.isAdmin) const CadastroImovelPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.azulEscuro,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3 && !authProvider.isAdmin) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Acesso restrito para administradores.'),
              ),
            );
          } else {
            mudancaDePage(index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Hotel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Pousada',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
        ],
      ),
    );
  }

  void _showPropertyDetails(Map<String, dynamic> imovel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesImovel(imovel: imovel),
      ),
    );
  }
}
