import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class WhatsAppService {
  static String generateWhatsAppMessage(String patientName, String appointmentDate, String appointmentTime, String notificationType) {
    // Format date to Brazilian format
    String formattedDate = appointmentDate;
    try {
      final DateTime date = DateTime.parse(appointmentDate);
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      formattedDate = appointmentDate;
    }
    
    if (notificationType == "1_day_before") {
      return """🦶 *Lembrete de Consulta - Podologia*

Olá $patientName! 👋

Este é um lembrete de que você tem uma consulta agendada para *amanhã* ($formattedDate) às *$appointmentTime*.

Por favor, confirme sua presença respondendo:
✅ *CONFIRMO* - se você comparecerá
❌ *CANCELAR* - se precisar cancelar

📍 Não se esqueça de trazer documentos e chegar com 10 minutos de antecedência.

Obrigado!""";
    } else {
      return """🦶 *Lembrete de Consulta - Podologia*

Olá $patientName! 👋

Sua consulta está próxima! 

📅 Data: *$formattedDate*
🕐 Horário: *$appointmentTime*

Você tem aproximadamente *1h30* para se preparar.

Por favor, confirme que está a caminho respondendo:
✅ *A CAMINHO* - se você está se dirigindo ao local
❌ *ATRASO* - se você vai se atrasar
❌ *CANCELAR* - se não puder comparecer

📍 Lembre-se de chegar com 10 minutos de antecedência.

Até logo!""";
    }
  }

  static String createWhatsAppLink(String phone, String message) {
    // Clean phone number (remove non-digits)
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Add Brazil country code if not present
    if (!cleanPhone.startsWith('55')) {
      cleanPhone = '55$cleanPhone';
    }
    
    // URL encode the message
    String encodedMessage = Uri.encodeComponent(message);
    
    return 'https://wa.me/$cleanPhone?text=$encodedMessage';
  }

  static Future<bool> sendWhatsAppMessage(String phone, String message) async {
    try {
      final String whatsappUrl = createWhatsAppLink(phone, message);
      final Uri uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      return false;
    }
  }

  static Future<bool> sendAppointmentReminder(String patientName, String phone, String appointmentDate, String appointmentTime, String notificationType) async {
    final String message = generateWhatsAppMessage(patientName, appointmentDate, appointmentTime, notificationType);
    return await sendWhatsAppMessage(phone, message);
  }

  static Future<bool> sendCustomMessage(String phone, String message) async {
    return await sendWhatsAppMessage(phone, message);
  }

  static String generateConfirmationMessage(String patientName, String appointmentDate, String appointmentTime) {
    String formattedDate = appointmentDate;
    try {
      final DateTime date = DateTime.parse(appointmentDate);
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      formattedDate = appointmentDate;
    }

    return """🦶 *Confirmação de Consulta - Podologia*

Olá $patientName! 👋

Sua consulta foi confirmada com sucesso:

📅 Data: *$formattedDate*
🕐 Horário: *$appointmentTime*

Lembrete importante:
📍 Chegue com 10 minutos de antecedência
📋 Traga documentos (RG, CPF)
👟 Use sapatos confortáveis

Caso precise cancelar ou remarcar, entre em contato com antecedência.

Obrigado!""";
  }

  static String generateCancellationMessage(String patientName, String appointmentDate, String appointmentTime) {
    String formattedDate = appointmentDate;
    try {
      final DateTime date = DateTime.parse(appointmentDate);
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      formattedDate = appointmentDate;
    }

    return """🦶 *Cancelamento de Consulta - Podologia*

Olá $patientName! 👋

Sua consulta foi cancelada:

📅 Data: *$formattedDate*
🕐 Horário: *$appointmentTime*

Para reagendar sua consulta, entre em contato conosco.

Obrigado pela compreensão!""";
  }

  static String generateCompletedMessage(String patientName) {
    return """🦶 *Consulta Finalizada - Podologia*

Olá $patientName! 👋

Sua consulta foi finalizada com sucesso.

📋 Recomendações importantes:
• Siga as orientações passadas durante a consulta
• Mantenha os cuidados com os pés
• Agende seu retorno conforme orientado

Caso tenha dúvidas, entre em contato conosco.

Obrigado pela confiança!""";
  }

  static bool isValidPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Brazilian phone numbers have 10 or 11 digits (with area code)
    return cleanPhone.length >= 10 && cleanPhone.length <= 11;
  }

  static String formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.length == 10) {
      // Format: (11) 9999-9999
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 11) {
      // Format: (11) 99999-9999
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    }
    
    return phone; // Return original if format is not recognized
  }
}