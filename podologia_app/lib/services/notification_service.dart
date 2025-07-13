import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/appointment.dart';
import '../models/patient.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleAppointmentNotifications(Appointment appointment, Patient patient) async {
    try {
      // Parse appointment date and time
      final DateTime appointmentDateTime = DateTime.parse('${appointment.date} ${appointment.time}:00');
      
      // Schedule notification 1 hour before
      final DateTime notificationTime = appointmentDateTime.subtract(const Duration(hours: 1));
      
      if (notificationTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: appointment.id.hashCode,
          title: '🦶 Consulta em 1 hora',
          body: 'Olá ${patient.name}! Sua consulta está próxima às ${appointment.time}.',
          scheduledTime: notificationTime,
          payload: 'appointment_${appointment.id}',
        );
      }
      
      // Schedule notification 10 minutes before
      final DateTime notificationTime10Min = appointmentDateTime.subtract(const Duration(minutes: 10));
      
      if (notificationTime10Min.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: appointment.id.hashCode + 1,
          title: '🦶 Consulta em 10 minutos',
          body: 'Olá ${patient.name}! Sua consulta começará em 10 minutos. Prepare-se!',
          scheduledTime: notificationTime10Min,
          payload: 'appointment_${appointment.id}',
        );
      }
      
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Consultas',
      channelDescription: 'Notificações de consultas agendadas',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      playSound: true,
    );
    
    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'immediate_channel',
      'Notificações Imediatas',
      channelDescription: 'Notificações imediatas do aplicativo',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );
    
    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> cancelAppointmentNotifications(String appointmentId) async {
    // Cancel both 1 hour and 10 minute notifications
    await cancelNotification(appointmentId.hashCode);
    await cancelNotification(appointmentId.hashCode + 1);
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Daily reminder to check appointments
  static Future<void> scheduleDailyReminder() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Lembrete Diário',
      channelDescription: 'Lembrete diário para verificar consultas',
      importance: Importance.medium,
      priority: Priority.medium,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    
    // Schedule for 9:00 AM daily
    await _notificationsPlugin.zonedSchedule(
      999, // Fixed ID for daily reminder
      '🦶 Lembrete Diário',
      'Verifique suas consultas agendadas para hoje!',
      _nextInstanceOfTime(9, 0),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Patient confirmation notification
  static Future<void> showPatientConfirmationNotification(String patientName, String appointmentTime) async {
    await showImmediateNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '✅ Presença Confirmada',
      body: 'Paciente $patientName confirmou presença para às $appointmentTime',
      payload: 'patient_confirmation',
    );
  }

  // Appointment reminder for professional
  static Future<void> showProfessionalReminder(String patientName, String appointmentTime) async {
    await showImmediateNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '👨‍⚕️ Lembrete Profissional',
      body: 'Consulta com $patientName às $appointmentTime está próxima',
      payload: 'professional_reminder',
    );
  }
}