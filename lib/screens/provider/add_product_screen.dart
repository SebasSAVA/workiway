import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/screens/provider/provider_products_screen.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/widgets/ConfirmationDialogWithButtons.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_dropdown.dart';
import 'package:workiway/widgets/input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workiway/services/product_service.dart'; // Asegúrate de crear este servicio

class AddProductScreen extends StatefulWidget {
  final String? userUid;
  final bool isEditing;
  final Map<String, dynamic>? existingProduct;

  const AddProductScreen({
    Key? key,
    this.userUid,
    this.isEditing = false,
    this.existingProduct,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _selectedCategory;
  String? _selectedCondition;

  String? _generalError; // Mensaje de error general

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingProduct != null) {
      _productNameController.text = widget.existingProduct!['name'] ?? '';
      _descriptionController.text =
          widget.existingProduct!['description'] ?? '';
      _priceController.text = widget.existingProduct!['price'].toString();
      _stockController.text = widget.existingProduct!['stock'].toString();
      _selectedCategory = widget.existingProduct!['category'];
      _selectedCondition = widget.existingProduct!['condition'];
    }
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
                  setState(() => _selectedImage = image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Seleccionar de Galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  setState(() => _selectedImage = image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para validar campos antes de guardar
  bool _validateFields() {
    bool isValid = true;

    // Resetear mensaje de error general
    setState(() {
      _generalError = null;
    });

    // Validaciones de campos obligatorios
    if (_productNameController.text.isEmpty) {
      isValid = false;
    }

    if (_selectedCategory == null) {
      isValid = false;
    }

    if (_descriptionController.text.isEmpty) {
      isValid = false;
    }

    if (_priceController.text.isEmpty ||
        double.tryParse(_priceController.text) == null) {
      isValid = false;
    }

    if (_stockController.text.isEmpty ||
        int.tryParse(_stockController.text) == null) {
      isValid = false;
    }

    if (_selectedImage == null &&
        (widget.existingProduct == null ||
            widget.existingProduct?['imageUrl'] == null)) {
      isValid = false;
    }

    // Mensaje de error si hay validaciones fallidas
    if (!isValid) {
      setState(() {
        _generalError = 'Por favor, completa todos los campos obligatorios.';
      });
    }

    return isValid;
  }

  Future<void> _saveProduct() async {
    if (!_validateFields()) return;
    print('Intentando guardar o actualizar el producto...');

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        final File imageFile = File(_selectedImage!.path);
        if (await imageFile.exists()) {
          final Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('productos/${DateTime.now().millisecondsSinceEpoch}');
          final UploadTask uploadTask = storageRef.putFile(imageFile);
          await uploadTask;
          imageUrl = await storageRef.getDownloadURL();
        } else {
          throw Exception('No se pudo encontrar la imagen seleccionada.');
        }
      } else {
        imageUrl = widget.existingProduct?['imageUrl'];
      }

      final productData = {
        'name': _productNameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'stock': int.parse(_stockController.text),
        'imageUrl': imageUrl,
      };

      if (widget.isEditing) {
        final String productId = widget.existingProduct?['id'] ?? '';
        if (productId.isEmpty) {
          throw Exception('ID del producto no encontrado.');
        }

        final docRef =
            FirebaseFirestore.instance.collection('productos').doc(productId);

        // Usamos `update` sin sobrescribir `providerId` u otros campos existentes.
        await docRef.update(productData);

        _showSuccessDialog('¡Producto actualizado con éxito!');
      } else {
        // Al crear un producto nuevo, incluimos `providerId`.
        productData['providerId'] = widget.userUid;

        await FirebaseFirestore.instance
            .collection('productos')
            .add(productData);
        _showSuccessDialog('¡Producto creado con éxito!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogWithButtons(
          mensaje: widget.isEditing
              ? '¿Estás seguro de que deseas actualizar este producto?'
              : '¿Estás seguro de que deseas crear este producto?',
          icono: Icons.warning,
          onAcceptPressed: () async {
            Navigator.of(context).pop(); // Cerrar el diálogo
            await _saveProduct(); // Llamar al guardado o actualización
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: Text(
          widget.isEditing ? 'Editar Producto' : 'Agregar Producto',
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
                      // Si se selecciona una imagen local, se muestra con Image.file
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      // Si es edición y tiene una URL, se muestra con Image.network
                      : widget.isEditing &&
                              widget.existingProduct?['imageUrl'] != null
                          ? Image.network(
                              widget.existingProduct!['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'Error al cargar imagen',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            )
                          // Texto informativo si no hay imagen
                          : const Text(
                              'Subir Imagen (JPG, PNG, JPEG) (obligatorio)',
                              style: TextStyle(color: Colors.black54),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InputField(
              controller: _productNameController,
              labelText: 'Nombre del Producto (obligatorio)',
              hintText: 'Ingresa el nombre del producto',
            ),
            const SizedBox(height: 10),
            CustomDropdown(
              label: 'Seleccionar Categoría (obligatorio)',
              value: _selectedCategory,
              items: Constants.productCategories,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {},
            ),
            const SizedBox(height: 10),
            InputField(
              controller: _descriptionController,
              labelText: 'Descripción (obligatorio)',
              hintText: 'Describe el producto',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: 'Seleccionar Condición (obligatorio)',
                    value: _selectedCondition,
                    items: Constants.productConditions,
                    onChanged: (value) {
                      setState(() {
                        _selectedCondition = value;
                      });
                    },
                    validator: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: _priceController,
                    labelText: 'Precio (obligatorio)',
                    hintText: 'Ingresa el precio del producto',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InputField(
                    controller: _stockController,
                    labelText: 'Stock (obligatorio)',
                    hintText: 'Ingresa la cantidad disponible',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_generalError != null)
              Text(_generalError!, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: widget.isEditing
                    ? 'Actualizar Producto'
                    : 'Guardar Producto',
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
