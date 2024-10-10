// services/error_handler.dart
class ErrorHandler {
  static String traducirErrorFirebase(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-not-found':
      case 'wrong-password':
        // Combina los errores de correo no encontrado y contraseña incorrecta
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo de nuevo más tarde.';
      case 'network-request-failed':
        return 'Hubo un problema de conexión a internet. Inténtalo más tarde.';
      case 'requires-recent-login':
        return 'Es necesario volver a iniciar sesión por razones de seguridad.';
      default:
        // Si no hay un código reconocido, mostrar un mensaje por defecto
        return 'Correo o contraseña incorrectos. Por favor, inténtalo de nuevo.';
    }
  }
}
