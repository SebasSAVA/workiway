import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/widgets/ConfirmationScreen.dart';
import 'package:workiway/widgets/custom_button.dart';
import 'package:workiway/widgets/custom_dropdown.dart';
import 'package:workiway/widgets/input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workiway/services/product_service.dart'; // Asegúrate de crear este servicio

class AddProductScreen extends StatefulWidget {
  final String? userUid;

  const AddProductScreen({Key? key, this.userUid}) : super(key: key);

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

  // Variables para mensajes de error específicos
  String? _generalError; // Mensaje de error general

  @override
  void initState() {
    super.initState();
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

  // Método para validar campos antes de guardar
  bool _validateFields() {
    bool isValid = true;

    // Resetear mensaje de error general
    setState(() {
      _generalError = null;
    });

    if (_productNameController.text.isEmpty) {
      isValid = false;
    }

    if (_selectedCategory == null) {
      isValid = false;
    }

    if (_priceController.text.isEmpty ||
        double.tryParse(_priceController.text) == null ||
        double.tryParse(_priceController.text)! < 0) {
      isValid = false;
    }

    if (_descriptionController.text.isEmpty) {
      isValid = false;
    }

    if (_stockController.text.isEmpty ||
        int.tryParse(_stockController.text) == null ||
        int.tryParse(_stockController.text)! < 1) {
      isValid = false;
    }

    if (_selectedImage == null) {
      isValid = false;
    }

    // Establecer el mensaje general si hay errores
    if (!isValid) {
      setState(() {
        _generalError =
            'Por favor, completa todos los campos obligatorios y asegúrate de que el precio y el stock sean válidos.';
      });
    }

    return isValid;
  }

  Future<void> _saveProduct() async {
    if (!_validateFields()) return; // Validar campos

    try {
      String? imageUrl;

      // Guardar la imagen en Firebase Storage si se seleccionó
      if (_selectedImage != null) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('productos/${DateTime.now().millisecondsSinceEpoch}');
        final UploadTask uploadTask =
            storageReference.putFile(File(_selectedImage!.path));
        await uploadTask;
        imageUrl = await storageReference.getDownloadURL();
      }

      final productData = {
        'name': _productNameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'providerId': widget.userUid, // Asociar el UID del proveedor
        'imageUrl': imageUrl, // Añadir el enlace de la imagen
      };

      // Llama a la función para guardar el producto en el servicio
      await ProductService().createProduct(productData);

      // Navegar a la pantalla de confirmación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            mensaje: '¡El producto ha sido creado con éxito!',
            icono: Icons.check_circle,
            onButtonPressed: () {
              Navigator.pop(context); // Cerrar la pantalla de confirmación
              Navigator.pop(
                  context); // Volver atrás a la lista de productos o pantalla principal
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el producto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF438ef9),
        title: const Text('Agregar Producto',
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
                text: 'Guardar Producto',
                onPressed: _saveProduct,
                type: ButtonType.PRIMARY,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
