import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_dropdown.dart';
import 'package:workiway/widgets/input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workiway/widgets/service_availability_dialog.dart';
import 'package:workiway/widgets/multi_select_dropdown.dart';
import 'package:workiway/utils/constants.dart';
import 'dart:io';
import 'package:workiway/services/provider_service.dart';
import 'package:workiway/services/service_service.dart';

class AddServiceScreen extends StatefulWidget {
  final String? userUid;

  const AddServiceScreen({Key? key, this.userUid}) : super(key: key);

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _paymentPercentageController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  List<String> _selectedDistricts = [];
  String? _selectedPaymentModalidad;
  bool _isPaymentAdvance = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Map<String, dynamic>? _providerData;
  bool _hasNoLocationDefined = false;
  Map<String, Map<String, String>>? _availability;

  // Variables para mensajes de error específicos
  String? _generalError; // Mensaje de error general

  // Lista de distritos filtrados
  List<String> _availableDistricts = [];

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cargarDatosProveedor();
    }
  }

  Future<void> _cargarDatosProveedor() async {
    try {
      DocumentSnapshot snapshot =
          await ProviderService().obtenerDatosProveedor();
      _providerData = snapshot.data() as Map<String, dynamic>?;

      setState(() {
        _hasNoLocationDefined = _providerData?['provincias'] == null ||
            (_providerData?['provincias']?.isEmpty == true);
      });

      // Cargar distritos basados en las provincias elegidas
      _availableDistricts = _getAvailableDistricts();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  List<String> _getAvailableDistricts() {
    // Verifica si hay provincias definidas
    if (_providerData?['provincias'] == null ||
        (_providerData!['provincias'] as List).isEmpty) {
      return []; // Retorna lista vacía si no hay provincias
    }

    List<String> districts = [];
    List<String> provinces =
        List<String>.from(_providerData!['provincias']); // Convertir a lista

    // Filtrar distritos solo de las provincias elegidas
    for (var province in provinces) {
      if (Constants.distritos.containsKey(province)) {
        districts
            .addAll(Constants.distritos[province]!); // Agregar los distritos
      }
    }

    return districts; // Retornar los distritos filtrados
  }

  void _selectImage() {
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

  void _showAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (context) => ServiceAvailabilityDialog(
        onAvailabilitySelected: (availability) {
          setState(() {
            _availability = availability;
          });
        },
      ),
    );
  }

  // Método para validar campos antes de guardar
  bool _validateFields() {
    bool isValid = true;

    // Resetear mensaje de error general
    setState(() {
      _generalError = null;
    });

    if (_serviceNameController.text.isEmpty) {
      isValid = false;
    }

    if (_selectedCategory == null) {
      isValid = false;
    }

    if (_priceController.text.isEmpty) {
      isValid = false;
    }

    if (_descriptionController.text.isEmpty) {
      // Verificar descripción
      isValid = false;
    }

    if (_selectedDistricts.isEmpty) {
      isValid = false; // Asegurarse de que se seleccionen distritos
    }

    if (_availability == null || _availability!.isEmpty) {
      isValid = false;
    }

    if (_selectedImage == null) {
      // Verificar imagen
      isValid = false;
    }

    // Establecer el mensaje general si hay errores
    if (!isValid) {
      setState(() {
        _generalError = 'Por favor, completa todos los campos obligatorios.';
      });
    }

    return isValid;
  }

  Future<void> _saveService() async {
    if (!_validateFields()) return; // Validar campos

    try {
      String? imageUrl;

      // Guardar la imagen en Firebase Storage si se seleccionó
      if (_selectedImage != null) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('services/${DateTime.now().millisecondsSinceEpoch}');
        final UploadTask uploadTask =
            storageReference.putFile(File(_selectedImage!.path));
        await uploadTask;
        imageUrl = await storageReference.getDownloadURL();
      }

      final serviceData = {
        'name': _serviceNameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'category': _selectedCategory,
        'subCategory': _selectedSubCategory,
        'districts': _selectedDistricts,
        'paymentModalidad': _selectedPaymentModalidad,
        'isPaymentAdvance': _isPaymentAdvance,
        'paymentPercentage': _paymentPercentageController.text,
        'availability': _availability,
        'providerId': widget.userUid, // Asociar el UID del proveedor
        'imageUrl': imageUrl, // Añadir el enlace de la imagen
      };

      // Llama a la función para guardar el servicio en un servicio separado
      await ServiceService().createService(serviceData);

      // Navegar a la pantalla de confirmación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            mensaje: '¡El servicio ha sido creado con éxito!',
            icono: Icons.check_circle,
            onButtonPressed: () {
              Navigator.pop(context); // Cerrar la pantalla de confirmación
              Navigator.pop(
                  context); // Volver atrás a la lista de servicios o pantalla principal
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar servicio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: const Text('Agregar Servicio',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Iconos en blanco
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _selectedImage != null
                      ? Image.file(File(_selectedImage!.path),
                          fit: BoxFit.cover)
                      : const Text(
                          'Subir Imagen (JPG, PNG, JPEG) (obligatorio)',
                          style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InputField(
              controller: _serviceNameController,
              labelText: 'Nombre del Servicio (obligatorio)',
              hintText: 'Ingresa el nombre del servicio',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: 'Seleccionar Categoría (obligatorio)',
                    value: _selectedCategory,
                    items: Constants.servicios.keys.toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _selectedSubCategory = null;
                      });
                    },
                    validator: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_selectedCategory != null) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomDropdown(
                      label: 'Seleccionar Sub-Categoría (opcional)',
                      value: _selectedSubCategory,
                      items: Constants.servicios[_selectedCategory] ?? [],
                      onChanged: (value) {
                        setState(() {
                          _selectedSubCategory = value;
                        });
                      },
                      validator: (value) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            InputField(
              controller: _descriptionController,
              labelText: 'Descripción (obligatorio)',
              hintText: 'Describe el servicio',
            ),
            const SizedBox(height: 10),
            MultiSelectDropdown(
              labelText: 'Seleccionar Distritos (obligatorio)',
              items: _availableDistricts,
              selectedItems: _selectedDistricts,
              onChanged: (List<String> selected) {
                setState(() {
                  _selectedDistricts = selected;
                });
              },
            ),
            const SizedBox(height: 10),
            if (_hasNoLocationDefined) ...[
              Text(
                  'Por favor define tu departamento y provincia antes de agregar un servicio.',
                  style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InputField(
                    controller: _priceController,
                    labelText: 'Precio (obligatorio)',
                    hintText: 'Ingresa el precio del servicio',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdown(
                    label: 'Modalidad (obligatorio)',
                    value: _selectedPaymentModalidad,
                    items: Constants.paymentModalities,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentModalidad = value;
                      });
                    },
                    validator: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showAvailabilityDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: const Center(
                  child: Text(
                      'Seleccionar Disponibilidad del Servicio (obligatorio)',
                      style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_availability != null) ...[
              Text('Disponibilidad seleccionada:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._availability!.entries.map((entry) {
                return Text(
                    '${entry.key}: ${entry.value['start']} - ${entry.value['end']}');
              }).toList(),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Activar pago anticipado (opcional)'),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPaymentAdvance = !_isPaymentAdvance;
                    });
                  },
                  child: Switch(
                    value: _isPaymentAdvance,
                    onChanged: (value) {
                      setState(() {
                        _isPaymentAdvance = value;
                      });
                    },
                    activeColor: Colors.lightGreen,
                  ),
                ),
              ],
            ),
            if (_isPaymentAdvance) ...[
              const SizedBox(height: 10),
              InputField(
                controller: _paymentPercentageController,
                labelText:
                    'Porcentaje de Pago por Adelantado (obligatorio si se activa)',
                hintText: 'Ingrese el porcentaje',
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            if (_generalError != null)
              Text(_generalError!, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Guardar Servicio',
                onPressed: _saveService,
                type: ButtonType.PRIMARY,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
