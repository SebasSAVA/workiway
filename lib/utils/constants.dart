import 'package:flutter/material.dart';

class Constants {
  static final Color primaryColor = const Color(0xFF438ef9);

  static final List<String> departamentos = ['Arequipa'];

  // Lista de tipos de usuario
  static final List<String> tiposUsuario = [
    'Cliente',
    'Proveedor de Servicios'
  ];

  static final Map<String, List<String>> provincias = {
    'Arequipa': [
      'Provincia de Arequipa',
      'Provincia de Camaná',
      'Provincia de Caravelí',
      'Provincia de Castilla',
      'Provincia de Caylloma',
      'Provincia de Condesuyos',
      'Provincia de Islay',
      'Provincia de La Unión'
    ],
  };

  static final Map<String, List<String>> distritos = {
    'Provincia de Arequipa': [
      'Arequipa',
      'Alto Selva Alegre',
      'Cayma',
      'Cerro Colorado',
      'Characato',
      //'Chiguata',
      //'Jacobo Hunter',
      //'La Joya',
      //'Mariano Melgar',
      'Miraflores',
      //'Mollebaya',
      //'Paucarpata',
      //'Pocsi',
      //'Polobaya',
      //'Quequeña',
      'Sabandía',
      //'Sachaca',
      //'San Juan de Siguas',
      //'San Juan de Tarucani',
      //'Santa Isabel de Siguas',
      //'Santa Rita de Siguas',
      //'Socabaya',
      //'Tiabaya',
      //'Uchumayo',
      //'Vítor',
      'Yanahuara',
      //'Yarabamba',
      //'Yura'
    ],
    'Provincia de Camaná': [
      'Camaná',
      //'José María Quimper',
      'Mariscal Cáceres',
      'Nicolás de Piérola',
      'Ocoña',
      'Quilca',
      'Samuel Pastor'
    ],
    'Provincia de Caravelí': [
      'Caravelí',
      'Acarí',
      'Atico',
      //'Atiquipa',
      'Bella Unión',
      //'Cahuacho',
      'Chala',
      //'Chaparra',
      //'Huanuhuanu',
      //'Jaqui',
      //'Lomas',
      //'Quicacha',
      'Yauca'
    ],
    'Provincia de Castilla': [
      'Aplao',
      //'Andagua',
      'Ayo',
      'Chachas',
      //'Chilcaymarca',
      'Choco',
      //'Huancarqui',
      //'Machaguay',
      'Orcopampa',
      'Pampacolca',
      //'Tipán',
      //'Uñón',
      'Uraca',
      'Viraco'
    ],
    'Provincia de Caylloma': [
      'Chivay',
      'Achoma',
      //'Cabanaconde',
      //'Callalli',
      'Cayarani',
      //'Coporaque',
      //'Huambo',
      //'Huanca',
      //'Ichupampa',
      'Lari',
      //'Lluta',
      //'Maca',
      //'Madrigal',
      'San Antonio de Chuca',
      //'Sibayo',
      'Tapay',
      //'Tisco',
      //'Tuti',
      //'Yanque'
    ],
    'Provincia de Condesuyos': [
      //'Chuquibamba',
      //'Andaray',
      //'Cayarani',
      'Chichas',
      //'Iray',
      'Río Grande',
      'Salamanca',
      'Yanaquihua'
    ],
    'Provincia de Islay': [
      'Mollendo',
      'Cocachacra',
      'Dean Valdivia',
      'Islay',
      //'Mejía',
      //'Punta de Bombón'
    ],
    'Provincia de La Unión': [
      'Cotahuasi',
      //'Alca',
      'Charcana',
      'Huaynacotas',
      'Pampamarca',
      //'Puyca',
      'Quechualla',
      //'Sayla',
      //'Tauría',
      //'Tomepampa',
      //'Toro'
    ],
  };

  // Categorías y subcategorías de servicios
  static final Map<String, List<String>> servicios = {
    'Reparaciones y Mantenimiento': [
      'Fontanería',
      'Electricidad',
      'Reparaciones Generales',
    ],
    'Instalaciones': [
      'Montaje de Muebles',
      'Pintura',
      'Instalación de Electrodomésticos',
    ],
    'Limpieza y Desinfección': [
      'Limpieza de Hogar',
      'Limpieza de Oficinas',
      'Desinfección de Espacios',
    ],
  };

  // Modalidades de pago
  static const List<String> paymentModalities = [
    'Por Hora',
    'Por Metro Cuadrado',
    'Por Proyecto',
  ];

  // Categorías de productos
  static const List<String> productCategories = [
    'Pintura',
    'Herramientas',
    'Materiales de Construcción',
    'Fontanería',
    'Electricidad',
    'Artículos de Limpieza',
  ];

  // Condiciones de productos
  static const List<String> productConditions = [
    'Nuevo',
    'Usado',
    'Abierto',
    'Defectuoso',
    'Reacondicionado',
  ];
}
