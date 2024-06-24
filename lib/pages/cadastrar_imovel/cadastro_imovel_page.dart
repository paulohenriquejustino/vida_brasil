import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_hotel/pages/home_page/home_page.dart';

class CadastroImovelPage extends StatefulWidget {
  const CadastroImovelPage({super.key});

  @override
  State<CadastroImovelPage> createState() => _CadastroImovelPageState();
}

class _CadastroImovelPageState extends State<CadastroImovelPage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _quartosController = TextEditingController();
  final TextEditingController _banheirosController = TextEditingController();
  final TextEditingController _camasController = TextEditingController();
  final TextEditingController _vagasController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _donoController = TextEditingController();
  final TextEditingController _metrosController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _avaliacaoController = TextEditingController();
  bool _possuiPiscina = false;
  bool _possuiWifi = false;
  bool _possuiArCondicionado = false;
  bool _possuiGaragem = false;
  bool _possuiAcademia = false;
  bool _localParaPet = false;
  String? _estadoSelecionado;
  String? _imovelSelecionado;
  bool isImagePickerActive = false;
  List<XFile> _selecionarImages = [];
  XFile? _imagemPrincipal;
  int id = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> cadastrarImovel(List<String> imageUrls, String? imagemPrincipalUrl) async {
  if (_formKey.currentState!.validate()) {
    if (imagemPrincipalUrl != null) {
      final dadosImovel = {
        'valor_imovel': double.parse(_valorController.text),
        'bairro': _bairroController.text,
        'quartos': int.parse(_quartosController.text),
        'banheiros': int.parse(_banheirosController.text),
        'vagas_carros': int.parse(_vagasController.text),
        'endereco': _enderecoController.text,
        'dono_do_imovel': _donoController.text,
        'metros_quadrados': _metrosController.text,
        'camas': _camasController.text,
        'cidade': _cidadeController.text,
        'avaliacao': _avaliacaoController.text,
        'estado': _estadoSelecionado,
        'tipo_de_imovel': _imovelSelecionado,
        'academia': _possuiAcademia,
        'garagem': _possuiGaragem,
        'ar_condicionado': _possuiArCondicionado,
        'wifi': _possuiWifi,
        'pet': _localParaPet,
        'piscina': _possuiPiscina,
        'imagens': imageUrls,
        'descricao': _descricaoController.text,
        'data': DateTime.now().toString(),
        'imagem_principal': imagemPrincipalUrl,
        'id': id
      };

      await FirebaseFirestore.instance.collection('imoveis').add(dadosImovel);
      print('Imóvel cadastrado com sucesso!');
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      print('Erro: A URL da imagem principal é nula.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer upload da imagem principal')),
      );
    }
  }
}

  Future<List<String>> uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _selecionarImages) {
      String? imageUrl = await uploadImage(image.path);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    return imageUrls;
  }

  Future<String?> uploadImage(String path) async {
    File file = File(path);
    try {
      String referencia = 'images/img-${DateTime.now().toString()}.jpg';
      await storage.ref(referencia).putFile(file);
      String imageUrl = await storage.ref(referencia).getDownloadURL();
      return imageUrl;
    } on FirebaseException catch (e) {
      print('Erro no upload da imagem: $e');
      return null;
    }
  }

  Future<String?> uploadImagemPrincipal() async {
    if (_imagemPrincipal != null) {
      return await uploadImage(_imagemPrincipal!.path);
    }
    return null;
  }

  Future<XFile?> getImage() async {
    if (!isImagePickerActive) {
      isImagePickerActive = true;
      try {
        XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        return image;
      } catch (e) {
        print('Erro ao selecionar a imagem: $e');
        return null;
      } finally {
        isImagePickerActive = false;
      }
    } else {
      print('Operação de seleção de imagem já está em andamento.');
      return null;
    }
  }

  verificarFoto() async {
    XFile? file = await getImage();
    if (file != null) {
      _selecionarImages.add(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cadastrar Imóvel',
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 25),
            width: 500,
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  // Campo do id
                  TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      hintText: 'Digite o valor do imóvel',
                      icon: Icon(
                        Icons.attach_money,
                        size: 27,
                        color: Colors.green,
                      ),
                      prefixText: 'R\$ ',
                      labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o valor';
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    controller: _donoController,
                    decoration: const InputDecoration(
                      labelText: 'Dono do imóvel',
                      hintText: 'Digite o nome do dono do imóvel',
                      icon: Icon(
                        Icons.person,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o dono do imóvel';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade do imóvel',
                      hintText: 'Digite a cidade do imóvel',
                      icon: Icon(
                        Icons.location_city,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a cidade do imóvel';
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    controller: _metrosController,
                    decoration: const InputDecoration(
                      labelText: 'Metros quadrados',
                      hintText: 'Digite o tamanho do imóvel',
                      icon: Icon(
                        Icons.square_foot,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o tamanho do imóvel';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço do imóvel',
                      hintText: 'Digite o endereço do imóvel',
                      icon: Icon(
                        Icons.house,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a localização';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição do imóvel',
                      hintText: 'Digite a descrição do imóvel',
                      icon: Icon(
                        Icons.description,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a descrição do imóvel';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _avaliacaoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Avaliação do imóvel',
                      hintText: 'Digite a avaliação do imóvel',
                      icon: Icon(
                        Icons.house,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a avaliação do imóvel';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bairroController,
                    decoration: const InputDecoration(
                      labelText: 'Bairro',
                      hintText: 'Digite o bairro do imóvel',
                      icon: Icon(
                        Icons.location_on,
                        size: 27,
                      ),
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a localização';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.location_on,
                        size: 27,
                      ),
                      hintText: 'Selecione o estado do imóvel',
                      labelText: 'Estado',
                      labelStyle: TextStyle(fontSize: 18),
                    ),
                    value: _estadoSelecionado,
                    items: ['MG', 'SP', 'RJ', 'ES', 'BA', 'PR', 'SC', 'RS', 'GO', 'DF']
                        .map((String estado) {
                      return DropdownMenuItem<String>(
                        value: estado,
                        child: Text(estado),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _estadoSelecionado = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione um estado';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Imóvel',
                      icon: Icon(
                        Icons.home,
                        size: 27,
                      ),
                      hintText: 'Selecione o tipo do imóvel',
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    value: _imovelSelecionado,
                    items: ['Pousada', 'Hotel'].map((String tipoImovel) {
                      return DropdownMenuItem<String>(
                        value: tipoImovel,
                        child: Text(tipoImovel),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _imovelSelecionado = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione o tipo de imóvel';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _quartosController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Quartos',
                      icon: Icon(
                        Icons.bed,
                        size: 27,
                      ),
                      hintText: 'Digite a quantidade de quartos do imóvel',
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número de quartos';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _banheirosController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Banheiros',
                      icon: Icon(
                        Icons.bathroom,
                        size: 27,
                      ),
                      hintText: 'Digite a quantidade de banheiros do imóvel',
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número de banheiros';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _camasController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Camas',
                      icon: Icon(
                        Icons.bed_outlined,
                        size: 27,
                      ),
                      hintText: 'Digite a quantidade de camas do imóvel',
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número de camas';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _vagasController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Vagas de Carro',
                      icon: Icon(
                        Icons.car_rental,
                        size: 27,
                      ),
                      hintText: 'Digite a quantidade de vagas de carros do imóvel',
                      labelStyle: TextStyle(fontSize: 18),
                      hintStyle: TextStyle(fontSize: 14),
                      helperStyle: TextStyle(fontSize: 14),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número de vagas de carro';
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Possui Academia',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    value: _possuiAcademia,
                    onChanged: (bool? value) {
                      setState(() {
                        _possuiAcademia = value!;
                      });
                    },
                    secondary: const Icon(
                      Icons.fitness_center,
                      size: 27,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Possui Garagem',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    value: _possuiGaragem,
                    onChanged: (bool? value) {
                      setState(() {
                        _possuiGaragem = value!;
                      });
                    },
                    secondary: const Icon(
                      Icons.garage,
                      size: 27,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Possui Piscina',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    value: _possuiPiscina,
                    onChanged: (bool? value) {
                      setState(() {
                        _possuiPiscina = value!;
                      });
                    },
                    secondary: const Icon(
                      Icons.pool,
                      size: 27,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Possui Ar Condicionado',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    value: _possuiArCondicionado,
                    onChanged: (bool? value) {
                      setState(() {
                        _possuiArCondicionado = value!;
                      });
                    },
                    secondary: const Icon(
                      Icons.ac_unit,
                      size: 27,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Possui Wi-Fi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    value: _possuiWifi,
                    onChanged: (bool? value) {
                      setState(() {
                        _possuiWifi = value!;
                      });
                    },
                    secondary: const Icon(
                      Icons.wifi,
                      size: 27,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Local para Pet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    value: _localParaPet,
                    onChanged: (bool? value) {
                      setState(() {
                        _localParaPet = value!;
                      });
                    },
                    secondary: const Icon(
                      Icons.pets,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(Icons.image),
                    label: const Text(
                      'Selecionar Imagens',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                      ),
                    ),
                    onPressed: () {
                      _selecionarImagens();
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(Icons.image),
                    label: const Text(
                      'Selecionar Imagem Principal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                      ),
                    ),
                    onPressed: () {
                      _selecionarImagemPrincipal();
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      if (_selecionarImages.isNotEmpty) {
                        List<String> imageUrls = await uploadImages();
                        String? imagemPrincipalUrl = await uploadImagemPrincipal();
                        if (imageUrls.isNotEmpty && imagemPrincipalUrl != null) {
                          await cadastrarImovel(imageUrls, imagemPrincipalUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erro ao fazer upload das imagens')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione as imagens do imóvel')),
                        );
                      }
                    },
                    child: const Text(
                      'Cadastrar Imóvel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selecionarImagens() {
    _picker
        .pickMultiImage()
        .then((List<XFile>? images) {
      if (images != null) {
        setState(() {
          _selecionarImages = images;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  void _selecionarImagemPrincipal() {
    _picker
        .pickImage(source: ImageSource.gallery)
        .then((XFile? image) {
      if (image != null) {
        setState(() {
          _imagemPrincipal = image;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }
}
