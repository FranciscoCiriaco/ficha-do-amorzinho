import 'package:uuid/uuid.dart';

class IdGenerator {
  static const Uuid _uuid = Uuid();

  static String generateId() {
    return _uuid.v4();
  }

  static String generatePatientId() {
    return 'patient_${_uuid.v4()}';
  }

  static String generateAnamnesisId() {
    return 'anamnesis_${_uuid.v4()}';
  }

  static String generateAppointmentId() {
    return 'appointment_${_uuid.v4()}';
  }

  static String generateNotificationId() {
    return 'notification_${_uuid.v4()}';
  }
}

class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (value.length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    // Remove all non-digit characters
    String cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Brazilian phone numbers have 10 or 11 digits (with area code)
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Telefone inválido';
    }
    
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    // Remove all non-digit characters
    String cleanCPF = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanCPF.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Check if all digits are the same
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanCPF)) {
      return 'CPF inválido';
    }
    
    // Validate CPF algorithm
    if (!_isValidCPF(cleanCPF)) {
      return 'CPF inválido';
    }
    
    return null;
  }

  static String? validateRG(String? value) {
    if (value == null || value.isEmpty) {
      return 'RG é obrigatório';
    }
    
    // Remove all non-digit characters except for X
    String cleanRG = value.replaceAll(RegExp(r'[^0-9X]'), '');
    
    if (cleanRG.length < 8 || cleanRG.length > 9) {
      return 'RG inválido';
    }
    
    return null;
  }

  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'CEP é obrigatório';
    }
    
    // Remove all non-digit characters
    String cleanCEP = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanCEP.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data é obrigatória';
    }
    
    try {
      DateTime date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Data não pode ser futura';
      }
    } catch (e) {
      return 'Data inválida';
    }
    
    return null;
  }

  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Horário é obrigatório';
    }
    
    final RegExp timeRegExp = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegExp.hasMatch(value)) {
      return 'Horário inválido (use formato HH:mm)';
    }
    
    return null;
  }

  static bool _isValidCPF(String cpf) {
    // Calculate first verification digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;
    
    if (digit1 != int.parse(cpf[9])) {
      return false;
    }
    
    // Calculate second verification digit
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;
    
    return digit2 == int.parse(cpf[10]);
  }
}

class TextFormatter {
  static String formatCPF(String cpf) {
    String cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCPF.length == 11) {
      return '${cleanCPF.substring(0, 3)}.${cleanCPF.substring(3, 6)}.${cleanCPF.substring(6, 9)}-${cleanCPF.substring(9)}';
    }
    return cpf;
  }

  static String formatPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.length == 10) {
      // Format: (11) 9999-9999
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 11) {
      // Format: (11) 99999-9999
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    }
    
    return phone;
  }

  static String formatCEP(String cep) {
    String cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCEP.length == 8) {
      return '${cleanCEP.substring(0, 5)}-${cleanCEP.substring(5)}';
    }
    return cep;
  }

  static String formatRG(String rg) {
    String cleanRG = rg.replaceAll(RegExp(r'[^0-9X]'), '');
    if (cleanRG.length == 9) {
      return '${cleanRG.substring(0, 2)}.${cleanRG.substring(2, 5)}.${cleanRG.substring(5, 8)}-${cleanRG.substring(8)}';
    }
    return rg;
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String removeAccents(String text) {
    const Map<String, String> accents = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c',
      'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ç': 'C',
    };
    
    String result = text;
    accents.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    
    return result;
  }
}