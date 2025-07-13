import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/anamnesis.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';
import '../utils/date_utils.dart' as date_utils;
import '../utils/validators.dart';
import 'patients_screen.dart';
import 'anamnesis_form_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;
  
  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Anamnesis> _anamnesisList = [];
  List<Appointment> _appointmentsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final anamnesis = await _databaseService.getAnamnesisByPatientId(widget.patient.id);
      final appointments = await _databaseService.getAppointmentsByPatientId(widget.patient.id);
      
      setState(() {
        _anamnesisList = anamnesis;
        _appointmentsList = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _deletePatient() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este paciente? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _databaseService.deletePatient(widget.patient.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente excluído com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir paciente: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditPatientScreen(patient: widget.patient),
                ),
              ).then((_) => _loadPatientData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePatient,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações do paciente
                  _buildPatientInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // Próximos agendamentos
                  _buildNextAppointments(),
                  
                  const SizedBox(height: 24),
                  
                  // Histórico de anamneses
                  _buildAnamnesisHistory(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnamnesisFormScreen(patient: widget.patient),
            ),
          ).then((_) => _loadPatientData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPatientInfo() {
    final age = date_utils.DateUtils.parseDate(widget.patient.birthDate) != null
        ? date_utils.DateUtils.getAge(date_utils.DateUtils.parseDate(widget.patient.birthDate)!)
        : 'N/A';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2E7D32),
                  child: Text(
                    widget.patient.name.isNotEmpty 
                        ? widget.patient.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$age anos • ${widget.patient.sex}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('Telefone', TextFormatter.formatPhone(widget.patient.contact)),
            _buildInfoRow('Data de Nascimento', 
                date_utils.DateUtils.formatDate(
                    date_utils.DateUtils.parseDate(widget.patient.birthDate) ?? DateTime.now())),
            _buildInfoRow('Profissão', widget.patient.profession),
            _buildInfoRow('Endereço', 
                '${widget.patient.address}, ${widget.patient.neighborhood}'),
            _buildInfoRow('Cidade', 
                '${widget.patient.city}, ${widget.patient.state}'),
            _buildInfoRow('CEP', TextFormatter.formatCEP(widget.patient.cep)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAppointments() {
    final futureAppointments = _appointmentsList.where((appointment) {
      final appointmentDate = date_utils.DateUtils.parseDate(appointment.date);
      return appointmentDate != null && appointmentDate.isAfter(DateTime.now());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Próximos Agendamentos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (futureAppointments.isEmpty)
              const Text(
                'Nenhum agendamento futuro',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              )
            else
              ...futureAppointments.map((appointment) => ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                title: Text(
                  date_utils.DateUtils.formatDate(
                      date_utils.DateUtils.parseDate(appointment.date) ?? DateTime.now()),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('${appointment.time} - ${appointment.status}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'confirm',
                      child: Text('Confirmar'),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancelar'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle appointment actions
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnamnesisHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico de Anamneses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnamnesisFormScreen(patient: widget.patient),
                      ),
                    ).then((_) => _loadPatientData());
                  },
                  child: const Text('Nova Anamnese'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_anamnesisList.isEmpty)
              const Text(
                'Nenhuma anamnese registrada',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              )
            else
              ..._anamnesisList.map((anamnesis) => ListTile(
                leading: const Icon(Icons.assignment, color: Color(0xFF2E7D32)),
                title: Text(
                  'Anamnese - ${date_utils.DateUtils.formatDate(anamnesis.createdAt)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  anamnesis.generalData.chiefComplaint.isNotEmpty
                      ? anamnesis.generalData.chiefComplaint
                      : 'Sem queixa principal registrada',
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('Visualizar'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicar'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnamnesisFormScreen(
                              patient: widget.patient,
                              anamnesis: anamnesis,
                              isViewOnly: true,
                            ),
                          ),
                        );
                        break;
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnamnesisFormScreen(
                              patient: widget.patient,
                              anamnesis: anamnesis,
                            ),
                          ),
                        ).then((_) => _loadPatientData());
                        break;
                      case 'duplicate':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnamnesisFormScreen(
                              patient: widget.patient,
                              anamnesis: anamnesis,
                              isDuplicate: true,
                            ),
                          ),
                        ).then((_) => _loadPatientData());
                        break;
                      case 'delete':
                        _deleteAnamnesis(anamnesis);
                        break;
                    }
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAnamnesis(Anamnesis anamnesis) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta anamnese?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _databaseService.deleteAnamnesis(anamnesis.id);
        _loadPatientData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anamnese excluída com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir anamnese: $e')),
          );
        }
      }
    }
  }
}