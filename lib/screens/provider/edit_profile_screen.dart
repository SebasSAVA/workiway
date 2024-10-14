import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Agregamos Firebase Storage
import 'package:workiway/services/provider_service.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_input_field.dart';
import 'package:workiway/widgets/multi_select_dropdown.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart'; // Importamos la pantalla de confirmación

class EditProfileScreen extends StatefulWidget {
  final String nombre;
  final String apellidos;
  final String telefono;

  const EditProfileScreen({
    Key? key,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _fotoPerfil; // Cambiamos el nombre de la variable

  // Controladores para los campos de texto
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _sobreTiController;
  late TextEditingController _porQueElegirmeController;

  // Listas para almacenar múltiples selecciones
  List<String> _selectedDepartamentos = [];
  List<String> _selectedProvincias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _apellidosController = TextEditingController(text: widget.apellidos);
    _telefonoController = TextEditingController(text: widget.telefono);
    _sobreTiController = TextEditingController();
    _porQueElegirmeController = TextEditingController();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      DocumentSnapshot docSnapshot =
          await ProviderService().obtenerDatosProveedor();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _sobreTiController.text = data['sobreTi'] ?? '';
          _porQueElegirmeController.text = data['porQueElegirme'] ?? '';
          _selectedDepartamentos =
              List<String>.from(data['departamentos'] ?? []);
          _selectedProvincias = List<String>.from(data['provincias'] ?? []);
          _fotoPerfil = data[
              'fotoPerfil']; // Guardamos la URL de la imagen como fotoPerfil
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
          _fotoPerfil = url; // Guardamos la URL como fotoPerfil
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  Future<void> _actualizarDatos() async {
    await _subirImagenAFirebase(); // Subir la imagen antes de actualizar los datos

    try {
      await ProviderService().actualizarDatosProveedor(
        nombre: _nombreController.text,
        apellidos: _apellidosController.text,
        telefono: _telefonoController.text,
        departamentos: _selectedDepartamentos,
        provincias: _selectedProvincias,
        sobreTi: _sobreTiController.text,
        porQueElegirme: _porQueElegirmeController.text,
        fotoPerfil:
            _fotoPerfil, // Guardamos la URL de la imagen como fotoPerfil
      );

      // Mostrar el mensaje de confirmación después de actualizar los datos
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationScreen(
            mensaje: '¡Datos actualizados con éxito!',
            icono: Icons.check_circle,
            onButtonPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo de éxito
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
            Navigator.of(context).pop(); // Cerrar el diálogo de confirmación
            await _actualizarDatos(); // Llamar a la actualización y luego mostrar éxito
          },
          onCancelPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar Foto'),
                onTap: () async {
                  Navigator.of(context).pop(); // Cierra el modal
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
                  Navigator.of(context).pop(); // Cierra el modal
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
        backgroundColor: const Color(0xFF438ef9), // Color azul personalizado
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
              color: Colors.white), // Cambiamos el color del texto a blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Iconos en blanco
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
              const SizedBox(height: 16),
              MultiSelectDropdown(
                labelText: 'Departamentos',
                items: Constants.departamentos,
                selectedItems: _selectedDepartamentos,
                onChanged: (List<String> selected) {
                  setState(() {
                    _selectedDepartamentos = selected;
                    _selectedProvincias = [];
                  });
                },
              ),
              const SizedBox(height: 16),
              MultiSelectDropdown(
                labelText: 'Provincias',
                items: _selectedDepartamentos.isEmpty
                    ? []
                    : Constants.provincias[_selectedDepartamentos.first] ?? [],
                selectedItems: _selectedProvincias,
                onChanged: (List<String> selected) {
                  setState(() {
                    _selectedProvincias = selected;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _porQueElegirmeController,
                labelText: 'Escribe una breve línea, ¿Por qué elegirme?',
                hintText: 'Describe por qué el cliente debe elegirte',
              ),
              CustomInputField(
                controller: _sobreTiController,
                labelText: 'Sobre ti',
                hintText: 'Escribe sobre ti',
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
