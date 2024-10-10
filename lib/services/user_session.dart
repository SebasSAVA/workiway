class UserSession {
  static final UserSession _instance = UserSession._internal();

  // Atributos comunes a ambos tipos de usuarios
  String? uid;
  String? nombre;
  String? apellidos;
  String? telefono;
  String? email;
  String? tipoUsuario;
  bool? emailVerified;

  // Atributos específicos para Cliente
  String? departamento;
  String? provincia;
  String? direccion;

  // Atributos específicos para Proveedor
  List<String>? departamentos;
  List<String>? provincias;
  String? porqueElegirme;
  String? sobreTi;
  List<dynamic>? anexiones;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  // Método para inicializar los datos del usuario cliente o proveedor
  void setUserData(Map<String, dynamic> userData) {
    uid = userData['uid'];
    nombre = userData['nombre'];
    apellidos = userData['apellidos'];
    telefono = userData['telefono'];
    email = userData['email'];
    tipoUsuario = userData['tipoUsuario'];
    emailVerified = userData['emailVerified'];

    if (tipoUsuario == 'Cliente') {
      departamento = userData['departamento'];
      provincia = userData['provincia'];
      direccion = userData['direccion'];
    } else if (tipoUsuario == 'Proveedor') {
      departamentos = List<String>.from(userData['departamentos'] ?? []);
      provincias = List<String>.from(userData['provincias'] ?? []);
      porqueElegirme = userData['porqueElegirme'];
      sobreTi = userData['sobreTi'];
      anexiones = userData['anexiones'];
    }
  }

  // Limpiar la sesión al cerrar sesión
  void clearSession() {
    uid = null;
    nombre = null;
    apellidos = null;
    telefono = null;
    email = null;
    tipoUsuario = null;
    emailVerified = null;
    departamento = null;
    provincia = null;
    direccion = null;
    departamentos = null;
    provincias = null;
    porqueElegirme = null;
    sobreTi = null;
    anexiones = null;
  }
}
