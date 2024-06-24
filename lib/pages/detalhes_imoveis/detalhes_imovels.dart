// ignore_for_file: unused_field

import 'package:app_hotel/pages/cores/cores_app.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TelaDetalhesImovel extends StatefulWidget {
  final Map<String, dynamic> imovel;

  const TelaDetalhesImovel({super.key, required this.imovel});

  @override
  // ignore: library_private_types_in_public_api
  _TelaDetalhesImovelState createState() => _TelaDetalhesImovelState();
}

class _TelaDetalhesImovelState extends State<TelaDetalhesImovel> {
  LatLng? _location;
  List<String> imagens = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchImages();
  }

  Future<void> _getLocation() async {
    try {
      List<Location> locations = await locationFromAddress(widget.imovel['endereco']);
      if (locations.isNotEmpty) {
        setState(() {
          _location = LatLng(locations.first.latitude, locations.first.longitude);
        });
      }
    } catch (e) {
      print('Erro em obter a localização $e');
    }
  }

  Future<void> _fetchImages() async {
    try {
      List<dynamic> photos = widget.imovel['imagens'] ?? [];
      setState(() {
        imagens = photos.cast<String>();
      });
       print(widget.imovel['imagens'] ?? []);
    } catch (e) {
      print('Erro em buscar as imagens $e');
    }
  }

  static const TextStyle tituloStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle subtituloStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle infoStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.azulEscuro,
  );
  static const TextStyle regularStyle = TextStyle(
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<Object>(
          stream: null,
          builder: (context, snapshot) {
            return Stack(
              children: [
                Hero(
                  tag: 'imagem_hero',
                  child: SizedBox(
                    height: size.height * 0.5,
                    child: CachedNetworkImage(
                      imageUrl: imagens[0],
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(0),
                          ),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),

                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.azulEscuro,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: IntrinsicWidth(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: widget.imovel['cidade'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ', ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.imovel['estado'].toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: size.height * 0.50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 65,
                                      width: 65,
                                      child: CachedNetworkImage(
                                        imageUrl: imagens[0],
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                            ),
                                          ),
                                        ),

                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Row do bairro, e dono do imovel.
                                        Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(right: 4),
                                              child: Icon(Icons.house_outlined, color: AppColors.azulEscuro, size: 24),
                                            ),
                                            Text(
                                              widget.imovel['bairro'],
                                              style: subtituloStyle,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(right: 4),
                                              child: Icon(Icons.location_city, color: AppColors.azulEscuro, size: 20),
                                            ),
                                            Text(
                                              widget.imovel['dono_do_imovel'],
                                              style: subtituloStyle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    // Row dos icones
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: AppColors.azulEscuro.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: IconButton(
                                              onPressed: () {
                                                // Abrir whatsapp
                                                _launchWhatsApp(
                                                  context,
                                                  widget.imovel['whatsapp'].toString(),
                                                );
                                              },
                                              icon: const FaIcon(
                                                FontAwesomeIcons.whatsapp,
                                                color: AppColors.azulEscuro,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: buildDefinindoEspacamentoIcons(widget.imovel),
                                ),
                              ),
                            ),
                            const Divider(
                              color: AppColors.azulEscuro,
                              thickness: 1.5,
                              height: 1,
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                'Descrição:',
                                style: tituloStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                widget.imovel['descricao'],
                                style: regularStyle,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Sobre o imóvel:',
                              style: subtituloStyle,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: FaIcon(
                                          FontAwesomeIcons.dollarSign,
                                          color: AppColors.azulEscuro,
                                          size: 20,
                                        ),
                                      ),
                                      Text(
                                        'Diária: ${widget.imovel['valor_imovel']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(Icons.location_on, color: AppColors.azulEscuro, size: 14),
                                      ),
                                      Text(
                                        'Endereço: ${widget.imovel['endereco']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(Icons.house_outlined, color: AppColors.azulEscuro, size: 20),
                                      ),
                                      Text(
                                        'Cidade: ${widget.imovel['cidade']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(Icons.house_rounded, color: AppColors.azulEscuro, size: 20),
                                      ),
                                      Text(
                                        'Estado: ${widget.imovel['estado']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(Icons.square_foot, color: AppColors.azulEscuro, size: 20),
                                      ),
                                      Text(
                                        'Metros quadrados: ${widget.imovel['metros_quadrados']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(Icons.house_outlined, color: AppColors.azulEscuro, size: 20),
                                      ),
                                      Text(
                                        'Bairro: ${widget.imovel['bairro']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(Icons.star, color: AppColors.azulEscuro, size: 20),
                                      ),
                                      Text(
                                        'Avaliação: ${widget.imovel['avaliacao']}',
                                        style: regularStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Adicionando o mapa
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Localização:',
                                style: tituloStyle,
                              ),
                            ),
                            _location != null
                                ? SizedBox(
                                    height: 200,
                                    child: GoogleMap(
                                      mapType: MapType.normal,
                                      onMapCreated: (controller) {},
                                      trafficEnabled: false,
                                      initialCameraPosition: CameraPosition(
                                        target: _location!,
                                        zoom: 15,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId('imovel'),
                                          draggable: false,
                                          position: _location!,
                                          infoWindow: InfoWindow(title: widget.imovel['endereco']),
                                          icon: BitmapDescriptor.defaultMarker,

                                        ),
                                      },
                                    ),
                                  )
                                : const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 15),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Fotos do imóvel:',
                                style: tituloStyle,
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 200,
                                  aspectRatio: 16/9,
                                  viewportFraction: 0.8,
                                  initialPage: 0,
                                  enlargeCenterPage: true,
                                  scrollDirection: Axis.horizontal,
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                ),
                                items: imagens.map((url) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                        child: CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,

                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              )
                            ),
                            const SizedBox(height: 15),
                            Center(
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.azulEscuro),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(8)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _launchWhatsApp(
                                    context,
                                    widget.imovel['whatsapp'].toString(),
                                  );
                                },
                                child: const Text(
                                  'Consultar disponibilidade',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildFeature(IconData iconData, String title, String value) {
    return Column(
      children: [
        Icon(
          iconData,
          color: AppColors.azulEscuro,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: regularStyle,
        ),
        Text(
          value,
          style: regularStyle,
        ),
      ],
    );
  }
  List<Widget> buildDefinindoEspacamentoIcons(Map<String, dynamic> imovel) {
    List<Widget> features = [
      buildFeature(Icons.bed, 'Quartos', imovel['quartos'].toString()),
      buildFeature(Icons.bathtub, 'Banheiros', imovel['banheiros'].toString()),
      buildFeature(Icons.kitchen, 'Camas', imovel['camas'].toString()),
      buildFeature(Icons.local_parking, 'Vagas', imovel['vagas_carros'].toString()),
      buildFeature(Icons.wifi, 'Wi-Fi', imovel['wifi'] ? 'Sim' : 'Não'),
      buildFeature(Icons.ac_unit, 'Ar Condicionado', imovel['ar_condicionado'] ? 'Sim' : 'Não'),
      buildFeature(Icons.beach_access, 'Piscina', imovel['piscina'] ? 'Sim' : 'Não'),
      buildFeature(Icons.fitness_center, 'Academia', imovel['academia'] ? 'Sim' : 'Não'),
      buildFeature(Icons.pets, 'Aceita Pets', imovel['pet'] ? 'Sim' : 'Não'),
    ];

    List<Widget> definindoEspacamentoIcons = [];
    for (int i = 0; i < features.length; i++) {
      definindoEspacamentoIcons.add(features[i]);
      if (i < features.length - 1) {
        definindoEspacamentoIcons.add(const SizedBox(width: 14));
      }
    }
    return definindoEspacamentoIcons;
  }
}

void _launchWhatsApp(BuildContext context, String phone) async {
  final TextEditingController messageController = TextEditingController();
  String phone = '5511 91042-4161';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        title: const Text('Digite sua mensagem'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: "Escreva sua mensagem aqui",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.black),
              gapPadding: 5,
            ),
            prefixIcon: Icon(Icons.message),
            suffixIcon: Icon(Icons.check),
            hintText: "Escreva sua mensagem aqui"),
        ),
        scrollable: true,
        actionsPadding: const EdgeInsets.all(16),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Enviar'),
            onPressed: () async {
              final message = messageController.text;
              final url = 'https://wa.me/$phone?text=${Uri.encodeFull(message)}';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Url não encontrada $url';
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
