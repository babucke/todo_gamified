// lib/utils/validators.dart

class Validators {
  // Validierung der E-Mail-Adresse
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte E-Mail eingeben';
    }
    // Regulärer Ausdruck für E-Mail-Validierung
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Bitte eine gültige E-Mail-Adresse eingeben';
    }
    return null;
  }

  // Validierung des Passworts (wie zuvor)
  static String? validatePassword(String? value) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return 'Bitte Passwort eingeben';
    } else if (!regex.hasMatch(value)) {
      return 'Passwort muss mindestens 8 Zeichen lang sein,\n'
          'einen Großbuchstaben, einen Kleinbuchstaben,\n'
          'eine Zahl und ein Sonderzeichen enthalten';
    } else {
      return null;
    }
  }
}
