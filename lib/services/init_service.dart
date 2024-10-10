import 'package:cloud_firestore/cloud_firestore.dart';

class InitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para inicializar las colecciones necesarias
  Future<void> initializeCollections() async {
    // Verificar si la colección 'clientes' ya existe
    DocumentSnapshot clienteDoc =
        await _firestore.collection('clientes').doc('template').get();
    if (!clienteDoc.exists) {
      // Si no existe, crear un documento de plantilla con los nuevos campos
      await _firestore.collection('clientes').doc('template').set({
        'nombre': 'Plantilla',
        'apellidos': 'Plantilla',
        'telefono': '123456789',
        'email': 'plantilla@ejemplo.com',
        'tipoUsuario': 'Cliente',
        'fotoPerfil': null, // Campo para foto de perfil (inicialmente vacío)
        'departamento': null, // Campo vacío para departamento
        'provincia': null, // Campo vacío para provincia
        'direccion': null, // Campo vacío para dirección
      });
    }

    // Verificar si la colección 'proveedores' ya existe
    DocumentSnapshot proveedorDoc =
        await _firestore.collection('proveedores').doc('template').get();
    if (!proveedorDoc.exists) {
      // Si no existe, crear un documento de plantilla con los nuevos campos
      await _firestore.collection('proveedores').doc('template').set({
        'nombre': 'Plantilla',
        'apellidos': 'Plantilla',
        'telefono': '123456789',
        'email': 'plantilla@ejemplo.com',
        'tipoUsuario': 'Proveedor',
        'fotoPerfil': null, // Campo para foto de perfil (inicialmente vacío)
        'departamentos': [], // Lista vacía para múltiples departamentos
        'provincias': [], // Lista vacía para múltiples provincias
        'porqueElegirme': null, // Campo vacío para "¿Por qué elegirme?"
        'sobreTi': null, // Campo vacío para "Sobre ti"
        'anexiones': [], // Lista vacía para anexiones
      });
    }
  }
}
