import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workiway/services/customer_service.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_input_field.dart';
import 'package:workiway/widgets/custom_dropdown.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart';

class EditCustomerProfileScreen extends StatefulWidget {
  final String nombre;
  final String apellidos;
  final String telefono;

  const EditCustomerProfileScreen({
    Key? key,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
  }) : super(key: key);

  @override
  _EditCustomerProfileScreenState createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _fotoPerfil;

  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  String? _selectedDepartamento;
  String? _selectedProvincia;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _apellidosController = TextEditingController(text: widget.apellidos);
    _telefonoController = TextEditingController(text: widget.telefono);
    _direccionController = TextEditingController();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      DocumentSnapshot docSnapshot =
          await CustomerService().obtenerDatosCliente();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _fotoPerfil = data['fotoPerfil'];
          _selectedDepartamento = data['departamento'] ?? '';
          _selectedProvincia = data['provincia'] ?? '';
          _direccionController.text = data['direccion'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _subirImagenAFirebase() async {
    if (_selectedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('imagenes_perfiles')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = await ref.putFile(File(_selectedImage!.path));
        final url = await uploadTask.ref.getDownloadURL();
        setState(() {
          _fotoPerfil = url;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  Future<void> _actualizarDatos() async {
    await _subirImagenAFirebase();

    try {
      await CustomerService().actualizarDatosCliente(
        nombre: _nombreController.text,
        apellidos: _apellidosController.text,
        telefono: _telefonoController.text,
        departamento: _selectedDepartamento ?? '',
        provincia: _selectedProvincia ?? '',
        direccion: _direccionController.text,
        fotoPerfil: _fotoPerfil,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationScreen(
            mensaje: '¡Datos actualizados con éxito!',
            icono: Icons.check_circle,
            onButtonPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogWithButtons(
          mensaje: '¿Estás seguro de que deseas actualizar tu perfil?',
          icono: Icons.warning,
          onAcceptPressed: () async {
            Navigator.of(context).pop();
            await _actualizarDatos();
          },
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar Foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    _selectedImage = image;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Seleccionar de Galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _selectedImage = image;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : (_fotoPerfil != null
                              ? NetworkImage(_fotoPerfil!)
                              : const AssetImage(
                                  'lib/assets/images/default_profile.png',
                                )) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF438ef9),
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomInputField(
                controller: _nombreController,
                labelText: 'Nombres',
                hintText: 'Ingresa tus nombres',
              ),
              CustomInputField(
                controller: _apellidosController,
                labelText: 'Apellidos',
                hintText: 'Ingresa tus apellidos',
              ),
              CustomInputField(
                controller: _telefonoController,
                labelText: 'Número de Contacto',
                hintText: 'Ingresa tu número de contacto',
              ),
              CustomDropdown(
                label: 'Departamento',
                value: _selectedDepartamento,
                items: Constants.departamentos,
                onChanged: (value) {
                  setState(() {
                    _selectedDepartamento = value;
                    _selectedProvincia = null; // Resetear la provincia
                  });
                },
                validator: (value) {},
              ),
              CustomDropdown(
                label: 'Provincia',
                value: _selectedProvincia,
                items: _selectedDepartamento != null &&
                        _selectedDepartamento!.isNotEmpty
                    ? Constants.provincias[_selectedDepartamento] ?? []
                    : [],
                onChanged: (value) {
                  setState(() {
                    _selectedProvincia = value;
                  });
                },
                validator: (value) {},
              ),
              CustomInputField(
                controller: _direccionController,
                labelText: 'Dirección',
                hintText: 'Ingresa tu dirección',
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Guardar cambios',
                  onPressed: _showConfirmationDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
