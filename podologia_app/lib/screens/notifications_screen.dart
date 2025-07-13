import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/whatsapp_service.dart';
import '../utils/date_utils.dart' as date_utils;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<NotificationModel> _notifications = [];
  List<Appointment> _todayAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final notifications = await _databaseService.getAllNotifications();
      final today = date_utils.DateUtils.formatDateForStorage(DateTime.now());
      final todayAppointments = await _databaseService.getAppointmentsByDate(today);
      
      setState(() {
        _notifications = notifications;
        _todayAppointments = todayAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar notificações: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Appointments
                    _buildTodayAppointments(),
                    
                    const SizedBox(height: 24),
                    
                    // Notification History
                    _buildNotificationHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTodayAppointments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultas de Hoje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_todayAppointments.isEmpty)
              const Text(
                'Nenhuma consulta agendada para hoje',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              )
            else
              ..._todayAppointments.map((appointment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(appointment.status),
                    child: Icon(
                      _getStatusIcon(appointment.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(appointment.patientName),
                  subtitle: Text(
                    '${appointment.time} • ${appointment.status}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _confirmAttendance(appointment),
                        tooltip: 'Confirmar Presença',
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _sendWhatsAppReminder(appointment),
                        tooltip: 'Enviar WhatsApp',
                      ),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Notificações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_notifications.isEmpty)
              const Text(
                'Nenhuma notificação registrada',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              )
            else
              ..._notifications.map((notification) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.sent ? Colors.green : Colors.orange,
                    child: Icon(
                      notification.sent ? Icons.check : Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(notification.patientName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consulta: ${date_utils.DateUtils.formatDate(
                          date_utils.DateUtils.parseDate(notification.appointmentDate) ?? DateTime.now()
                        )} às ${notification.appointmentTime}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.notificationType == '1_day_before' 
                            ? 'Lembrete 1 dia antes'
                            : 'Lembrete 1h30 antes',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: notification.sent
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : TextButton(
                          onPressed: () => _sendNotification(notification),
                          child: const Text('Enviar'),
                        ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _confirmAttendance(Appointment appointment) async {
    try {
      final updatedAppointment = appointment.copyWith(status: 'confirmed');
      await _databaseService.updateAppointment(updatedAppointment);
      
      // Show local notification
      await NotificationService.showPatientConfirmationNotification(
        appointment.patientName,
        appointment.time,
      );
      
      _loadNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Presença de ${appointment.patientName} confirmada!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar presença: $e')),
        );
      }
    }
  }

  Future<void> _sendWhatsAppReminder(Appointment appointment) async {
    try {
      final patient = await _databaseService.getPatientById(appointment.patientId);
      if (patient != null) {
        final success = await WhatsAppService.sendAppointmentReminder(
          patient.name,
          patient.contact,
          appointment.date,
          appointment.time,
          "1_hour_30_before",
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                  ? 'Lembrete WhatsApp enviado para ${patient.name}!'
                  : 'Erro ao enviar lembrete WhatsApp'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar lembrete: $e')),
        );
      }
    }
  }

  Future<void> _sendNotification(NotificationModel notification) async {
    try {
      final success = await WhatsAppService.sendWhatsAppMessage(
        notification.patientContact,
        notification.message,
      );
      
      if (success) {
        final updatedNotification = notification.copyWith(sent: true);
        await _databaseService.updateNotification(updatedNotification);
        _loadNotifications();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Notificação enviada com sucesso!'
                : 'Erro ao enviar notificação'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar notificação: $e')),
        );
      }
    }
  }
}