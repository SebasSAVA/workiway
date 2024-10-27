import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/screens/provider/provider_services_screen.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
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
  final bool isEditing; // Indica si es edición o creación
  final Map<String, dynamic>? existingService; // Datos del servicio a editar
  final String? serviceId; // ID del servicio a editar

  const AddServiceScreen({
    Key? key,
    this.userUid,
    this.isEditing = false, // Valor por defecto es 'false' (creación)
    this.existingService,
    this.serviceId, // Recibe el ID del servicio explícitamente
  }) : super(key: key);

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  String? _serviceId;
  // Controladores inicializados con valores si es edición
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

  // Inicialización de variables según sea creación o edición
  @override
  void initState() {
    super.initState();

    _serviceId = widget.existingService?['id'] ?? widget.serviceId;

    print('ID del servicio en AddServiceScreen: $_serviceId');
    print('Datos completos del servicio: ${widget.existingService}');
    _serviceId = (_serviceId ?? '').trim();

    _cargarDatosProveedor();

    if (widget.isEditing && widget.existingService != null) {
      _serviceNameController.text = widget.existingService!['name'] ?? '';
      _descriptionController.text =
          widget.existingService!['description'] ?? '';
      _priceController.text = widget.existingService!['price'].toString();
      _selectedCategory = widget.existingService!['category'];
      _selectedSubCategory = widget.existingService!['subCategory'];
      _selectedDistricts =
          List<String>.from(widget.existingService!['districts'] ?? []);
      _selectedPaymentModalidad = widget.existingService!['paymentModalidad'];
      _isPaymentAdvance = widget.existingService!['isPaymentAdvance'] ?? false;

      if (widget.existingService!['availability'] != null) {
        _availability = (widget.existingService!['availability']
                as Map<String, dynamic>)
            .map(
                (key, value) => MapEntry(key, Map<String, String>.from(value)));
      }

      _paymentPercentageController.text =
          widget.existingService!['paymentPercentage'] ?? '';
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

        // Cargar los distritos correspondientes a las provincias seleccionadas
        _availableDistricts = _getAvailableDistricts();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  List<String> _getAvailableDistricts() {
    if (_providerData?['provincias'] == null ||
        (_providerData!['provincias'] as List).isEmpty) {
      return []; // Retorna lista vacía si no hay provincias
    }

    List<String> districts = [];
    List<String> provinces = List<String>.from(_providerData!['provincias']);

    // Agrega los distritos correspondientes a las provincias seleccionadas
    for (var province in provinces) {
      if (Constants.distritos.containsKey(province)) {
        districts.addAll(Constants.distritos[province]!);
      }
    }
    return districts;
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

    // Validar campos obligatorios
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
      isValid = false;
    }

    if (_selectedDistricts.isEmpty) {
      isValid = false;
    }

    if (_availability == null || _availability!.isEmpty) {
      isValid = false;
    }

    // Validar que exista una imagen (ya sea nueva o existente)
    if (_selectedImage == null &&
        (widget.existingService == null ||
            widget.existingService?['imageUrl'] == null)) {
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogWithButtons(
          mensaje: widget.isEditing
              ? '¿Estás seguro de que deseas actualizar este servicio?'
              : '¿Estás seguro de que deseas crear este servicio?',
          icono: Icons.warning,
          onAcceptPressed: () async {
            Navigator.of(context).pop(); // Cerrar el diálogo
            await _saveService(); // Llamar al guardado o actualización
          },
          onCancelPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
          },
        );
      },
    );
  }

  void _showSuccessDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationScreen(
          mensaje: mensaje,
          icono: Icons.check_circle,
          onButtonPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo de éxito
            Navigator.pop(context); // Volver a la pantalla anterior
          },
        );
      },
    );
  }

  // Método para guardar o actualizar el servicio
  Future<void> _saveService() async {
    if (!_validateFields()) return;
    print('Intentando guardar o actualizar el servicio con ID: $_serviceId');

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        final File imageFile = File(_selectedImage!.path);

        if (await imageFile.exists()) {
          final Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('services/${DateTime.now().millisecondsSinceEpoch}');
          final UploadTask uploadTask = storageReference.putFile(imageFile);
          await uploadTask;
          imageUrl = await storageReference.getDownloadURL();
        } else {
          throw Exception('No se pudo encontrar la imagen seleccionada.');
        }
      } else {
        imageUrl = widget.existingService?['imageUrl'];
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
        'providerId': widget.userUid,
        'imageUrl': imageUrl,
      };

      if (widget.isEditing) {
        if (_serviceId == null || _serviceId!.isEmpty) {
          throw Exception('El ID del servicio no se proporcionó.');
        }

        final docRef =
            FirebaseFirestore.instance.collection('servicios').doc(_serviceId);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          throw Exception('El servicio no existe o fue eliminado.');
        }

        await docRef.update(serviceData);
        _showSuccessDialog('¡Servicio actualizado con éxito!');
      } else {
        await FirebaseFirestore.instance
            .collection('servicios')
            .add(serviceData);
        _showSuccessDialog('¡Servicio creado con éxito!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: Text(
          widget.isEditing ? 'Editar Servicio' : 'Agregar Servicio',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      // Mostrar imagen seleccionada localmente
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      // Si está en edición, mostrar la imagen remota desde la URL
                      : widget.isEditing &&
                              widget.existingService?['imageUrl'] != null
                          ? Image.network(
                              widget.existingService!['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'Error al cargar imagen',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            )
                          // Texto por defecto si no hay imagen
                          : const Text(
                              'Subir Imagen (JPG, PNG, JPEG) (obligatorio)',
                              style: TextStyle(color: Colors.black54),
                            ),
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
                text: widget.isEditing
                    ? 'Actualizar Servicio'
                    : 'Guardar Servicio',
                onPressed: _showConfirmationDialog,
                type: ButtonType.PRIMARY,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
