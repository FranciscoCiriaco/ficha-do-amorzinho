import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/whatsapp_service.dart';
import '../utils/validators.dart';
import '../utils/date_utils.dart' as date_utils;

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Appointment> _appointments = [];
  List<Appointment> _dayAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final appointments = await _databaseService.getAllAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
      
      _loadDayAppointments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
        );
      }
    }
  }

  void _loadDayAppointments() {
    final selectedDateStr = date_utils.DateUtils.formatDateForStorage(_selectedDay);
    setState(() {
      _dayAppointments = _appointments.where((appointment) {
        return appointment.date == selectedDateStr;
      }).toList();
    });
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    final dayStr = date_utils.DateUtils.formatDateForStorage(day);
    return _appointments.where((appointment) {
      return appointment.date == dayStr;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Appointment>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    markerDecoration: BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  locale: 'pt_BR',
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadDayAppointments();
                  },
                ),
                
                const SizedBox(height: 16),
                
                Expanded(
                  child: _dayAppointments.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum agendamento para ${date_utils.DateUtils.formatDate(_selectedDay)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _dayAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _dayAppointments[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(appointment.status),
                                  child: Icon(
                                    _getStatusIcon(appointment.status),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(appointment.patientName),
                                subtitle: Text(
                                  '${appointment.time} • ${appointment.status}',
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'confirm',
                                      child: Text('Confirmar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'complete',
                                      child: Text('Concluir'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'cancel',
                                      child: Text('Cancelar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'whatsapp',
                                      child: Text('Enviar WhatsApp'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    _handleAppointmentAction(appointment, value as String);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          ).then((_) => _loadAppointments());
        },
        child: const Icon(Icons.add),
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

  Future<void> _handleAppointmentAction(Appointment appointment, String action) async {
    switch (action) {
      case 'confirm':
        await _updateAppointmentStatus(appointment, 'confirmed');
        break;
      case 'complete':
        await _updateAppointmentStatus(appointment, 'completed');
        break;
      case 'cancel':
        await _updateAppointmentStatus(appointment, 'cancelled');
        break;
      case 'whatsapp':
        await _sendWhatsAppMessage(appointment);
        break;
    }
  }

  Future<void> _updateAppointmentStatus(Appointment appointment, String status) async {
    try {
      final updatedAppointment = appointment.copyWith(status: status);
      await _databaseService.updateAppointment(updatedAppointment);
      _loadAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agendamento ${status == 'confirmed' ? 'confirmado' : status == 'completed' ? 'concluído' : 'cancelado'}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar agendamento: $e')),
        );
      }
    }
  }

  Future<void> _sendWhatsAppMessage(Appointment appointment) async {
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
                  ? 'WhatsApp enviado com sucesso!'
                  : 'Erro ao enviar WhatsApp'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar WhatsApp: $e')),
        );
      }
    }
  }
}

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _databaseService.getAllPatients();
      setState(() {
        _patients = patients;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pacientes: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = date_utils.DateUtils.formatDateForStorage(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um paciente')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointment = Appointment(
        id: IdGenerator.generateAppointmentId(),
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.name,
        date: _dateController.text,
        time: _timeController.text,
        status: 'scheduled',
        createdAt: DateTime.now(),
      );
      
      await _databaseService.insertAppointment(appointment);
      
      // Schedule notifications
      await NotificationService.scheduleAppointmentNotifications(appointment, _selectedPatient!);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento criado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar agendamento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAppointment,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<Patient>(
                value: _selectedPatient,
                decoration: const InputDecoration(
                  labelText: 'Paciente',
                  border: OutlineInputBorder(),
                ),
                items: _patients.map((patient) {
                  return DropdownMenuItem(
                    value: patient,
                    child: Text(patient.name),
                  );
                }).toList(),
                onChanged: (patient) {
                  setState(() {
                    _selectedPatient = patient;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione um paciente';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => FormValidator.validateRequired(value, 'Data'),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Horário',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: _selectTime,
                validator: (value) => FormValidator.validateRequired(value, 'Horário'),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAppointment,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Criar Agendamento',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}