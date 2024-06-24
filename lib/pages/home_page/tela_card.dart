import 'dart:async';
import 'package:app_hotel/pages/cores/cores_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

class TelaCardImoveisHome extends StatefulWidget {
  final List<String> listaDeLugares;
  final Function(Map<String, dynamic>) detalhesImovel;

  const TelaCardImoveisHome({
    super.key,
    required this.listaDeLugares,
    required this.detalhesImovel,
  });

  @override
  _TelaCardImoveisHomeState createState() => _TelaCardImoveisHomeState();
}

class _TelaCardImoveisHomeState extends State<TelaCardImoveisHome> {
  String? filtroSelecionado;
  String buscaCidade = "";
  String cidadeSelecionada = "";
  int? numeroCamas;
  int? numeroBanheiros;

  final TextEditingController buscaController = TextEditingController();
  Timer? _debounce;
  List<String> cidades = [];
  String? cidadeDropdownValue;

  @override
  void initState() {
    super.initState();
    buscaController.addListener(_onBuscaChanged);
    _carregarCidades();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    buscaController.removeListener(_onBuscaChanged);
    buscaController.dispose();
    super.dispose();
  }

  void _onBuscaChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        buscaCidade = buscaController.text.toLowerCase();
      });
    });
  }

  Future<void> _carregarCidades() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('imoveis').get();
    Set<String> cidadesSet = {};
    for (var doc in snapshot.docs) {
      cidadesSet.add(doc['cidade'].toString());
    }
    setState(() {
      cidades = cidadesSet.toList();
    });
  }

  void _filtroDropDown() {
    // Buscar as cidades do Firestore database e preencher o dropdown
    _carregarCidades().then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: const Text("Selecione a cidade",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              )),
            content: DropdownButton<String>(
              isExpanded: true,
              elevation: 1,
              hint: const Text("Selecione a cidade"),
              value: cidadeDropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  cidadeDropdownValue = newValue;
                  cidadeSelecionada = newValue ?? "";
                });
                Navigator.of(context).pop();
              },
              items: cidades.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                child: const Text("Fechar",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Query imoveisQuery = FirebaseFirestore.instance.collection('imoveis');
    if (filtroSelecionado == 'maior_preco') {
      imoveisQuery = imoveisQuery.orderBy('valor_imovel', descending: true);
    } else if (filtroSelecionado == 'menor_preco') {
      imoveisQuery = imoveisQuery.orderBy('valor_imovel', descending: false);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<QuerySnapshot>(
          stream: imoveisQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('Nenhum imóvel encontrado.'),
              );
            }
            final imoveis = snapshot.data!.docs;
            List<DocumentSnapshot> imoveisFiltrados = imoveis;

            if (filtroSelecionado != null &&
                filtroSelecionado != 'todos' &&
                filtroSelecionado != 'maior_preco' &&
                filtroSelecionado != 'menor_preco') {
              imoveisFiltrados = imoveis.where((imovel) =>
                  imovel['tipo_de_imovel'].toString().toLowerCase() ==
                  filtroSelecionado).toList();
            }

            if (buscaCidade.isNotEmpty) {
              imoveisFiltrados = imoveisFiltrados.where((imovel) =>
                  imovel['cidade'].toString().toLowerCase().contains(buscaCidade)).toList();
            }

            if (cidadeSelecionada.isNotEmpty) {
              imoveisFiltrados = imoveisFiltrados.where((imovel) =>
                  imovel['cidade'].toString().toLowerCase() == cidadeSelecionada.toLowerCase()).toList();
            }

            if (numeroCamas != null) {
              imoveisFiltrados = imoveisFiltrados.where((imovel) =>
                  imovel['camas'] == numeroCamas).toList();
            }

            if (numeroBanheiros != null) {
              imoveisFiltrados = imoveisFiltrados.where((imovel) =>
                  imovel['banheiros'] == numeroBanheiros).toList();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black54,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  keyboardAppearance: Brightness.dark,
                                  keyboardType: TextInputType.name,
                                  controller: buscaController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 28,
                                      color: AppColors.azulEscuro,
                                    ),
                                    hintText: 'Buscar por cidade',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          buscaController.clear();
                                          buscaCidade = '';
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 24,
                                        color: AppColors.azulEscuro,
                                      ),
                                    ),
                                    hintStyle: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _filtroDropDown,
                                icon: const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 28,
                                  color: AppColors.azulEscuro,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 6, top: 16, right: 16, left: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filtroSelecionado = 'hotel';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filtroSelecionado == 'hotel'
                                ? AppColors.azulEscuro
                                : Colors.white,
                            foregroundColor: filtroSelecionado == 'hotel'
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filtroSelecionado == 'hotel'
                                    ? AppColors.azulEscuro
                                    : AppColors.azulEscuro,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Hotel',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filtroSelecionado = 'pousada';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filtroSelecionado == 'pousada'
                                ? AppColors.azulEscuro
                                : Colors.white,
                            foregroundColor: filtroSelecionado == 'pousada'
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filtroSelecionado == 'pousada'
                                    ? AppColors.azulEscuro
                                    : Colors.black,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Pousada',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filtroSelecionado = 'todos';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filtroSelecionado == 'todos'
                                ? AppColors.azulEscuro
                                : Colors.white,
                            foregroundColor: filtroSelecionado == 'todos'
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filtroSelecionado == 'todos'
                                    ? AppColors.azulEscuro
                                    : Colors.black,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Todos',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filtroSelecionado = 'maior_preco';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filtroSelecionado == 'maior_preco'
                                ? AppColors.azulEscuro
                                : Colors.white,
                            foregroundColor: filtroSelecionado == 'maior_preco'
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filtroSelecionado == 'maior_preco'
                                    ? AppColors.azulEscuro
                                    : Colors.black,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Maior Preço',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filtroSelecionado = 'menor_preco';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filtroSelecionado == 'menor_preco'
                                ? AppColors.azulEscuro
                                : Colors.white,
                            foregroundColor: filtroSelecionado == 'menor_preco'
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: filtroSelecionado == 'menor_preco'
                                    ? AppColors.azulEscuro
                                    : Colors.black,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Menor Preço',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(4),
                Expanded(
                  child: ListView.builder(
                    itemCount: imoveisFiltrados.length,
                    itemBuilder: (context, index) {
                      final imovel = imoveisFiltrados[index];
                      return GestureDetector(
                        onTap: () {
                          widget.detalhesImovel(imovel.data() as Map<String, dynamic>);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppColors.azulEscuro.withOpacity(0.4),
                            ),
                          ),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            color: Colors.white,
                            height: 300,
                            child: Column(
                              children: [
                                Expanded(
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('imoveis')
                                        .doc(imovel.id)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (!snapshot.hasData || !snapshot.data!.exists) {
                                        return const Center(
                                          child: Text('Sem imagens.'),
                                        );
                                      }
                                      final imovelData = snapshot.data!.data() as Map<String, dynamic>;
                                      final List<String> imagens = List<String>.from(imovelData['imagens'] ?? []);
                                      if (imagens.isEmpty) {
                                        return const Center(
                                          child: Text('Sem imagens.'),
                                        );
                                      }
                                      return CarouselSlider.builder(
                                        itemCount: imagens.length,
                                        itemBuilder: (context, index, realIndex) {
                                          return CachedNetworkImage(
                                            imageUrl: imagens[index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) => const Center(
                                              child: Icon(Icons.error),
                                            ),
                                          );
                                        },
                                        options: CarouselOptions(
                                          autoPlay: true,
                                          height: double.infinity,
                                          viewportFraction: 1.0,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: imovel['cidade'].toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.azulEscuro,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ', ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.azulEscuro,
                                              ),
                                            ),
                                            TextSpan(
                                              text: imovel['estado'].toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.azulEscuro,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Gap(4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: AppColors.azulEscuro,
                                          ),
                                          const Gap(4),
                                          Text(
                                            imovel['endereco'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.azulEscuro,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.apartment,
                                            size: 18,
                                            color: AppColors.azulEscuro,
                                          ),
                                          const Gap(4),
                                          Text(
                                            imovel['tipo_de_imovel'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.azulEscuro,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 4,),
                                          Row(
                                            children: [
                                              const FaIcon(
                                                FontAwesomeIcons.dollarSign,
                                                size: 18,
                                                color: AppColors.azulEscuro,
                                              ),
                                              const Gap(4),
                                              Text(
                                                'Diária: R\$ ${imovel['valor_imovel']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.azulEscuro,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Gap(4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
