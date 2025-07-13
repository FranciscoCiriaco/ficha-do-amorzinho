import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../utils/validators.dart';
import '../utils/date_utils.dart' as date_utils;
import 'patient_details_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final patients = await _databaseService.getAllPatients();
      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pacientes: $e')),
        );
      }
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          return patient.name.toLowerCase().contains(query.toLowerCase()) ||
                 patient.contact.contains(query) ||
                 patient.birthDate.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome, telefone ou data de nascimento',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Lista de pacientes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum paciente encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPatients,
                        child: ListView.builder(
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  child: Text(
                                    patient.name.isNotEmpty 
                                        ? patient.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  patient.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TextFormatter.formatPhone(patient.contact),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Nascimento: ${date_utils.DateUtils.formatDate(
                                        date_utils.DateUtils.parseDate(patient.birthDate) ?? DateTime.now()
                                      )}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientDetailsScreen(
                                        patient: patient,
                                      ),
                                    ),
                                  ).then((_) => _loadPatients());
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPatientScreen(),
            ),
          ).then((_) => _loadPatients());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;
  
  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _cepController;
  late TextEditingController _birthDateController;
  late TextEditingController _professionController;
  late TextEditingController _contactController;
  
  String _selectedSex = 'Masculino';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _addressController = TextEditingController(text: widget.patient?.address ?? '');
    _neighborhoodController = TextEditingController(text: widget.patient?.neighborhood ?? '');
    _cityController = TextEditingController(text: widget.patient?.city ?? '');
    _stateController = TextEditingController(text: widget.patient?.state ?? '');
    _cepController = TextEditingController(text: widget.patient?.cep ?? '');
    _birthDateController = TextEditingController(text: widget.patient?.birthDate ?? '');
    _professionController = TextEditingController(text: widget.patient?.profession ?? '');
    _contactController = TextEditingController(text: widget.patient?.contact ?? '');
    
    if (widget.patient != null) {
      _selectedSex = widget.patient!.sex;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.patient != null 
          ? date_utils.DateUtils.parseDate(widget.patient!.birthDate) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthDateController.text = date_utils.DateUtils.formatDateForStorage(picked);
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final patient = Patient(
        id: widget.patient?.id ?? IdGenerator.generatePatientId(),
        name: TextFormatter.capitalizeWords(_nameController.text),
        address: _addressController.text,
        neighborhood: _neighborhoodController.text,
        city: _cityController.text,
        state: _stateController.text,
        cep: _cepController.text,
        birthDate: _birthDateController.text,
        sex: _selectedSex,
        profession: _professionController.text,
        contact: _contactController.text,
        createdAt: widget.patient?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.patient == null) {
        await _databaseService.insertPatient(patient);
      } else {
        await _databaseService.updatePatient(patient);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.patient == null 
                ? 'Paciente cadastrado com sucesso!'
                : 'Paciente atualizado com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar paciente: $e')),
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
        title: Text(widget.patient == null ? 'Novo Paciente' : 'Editar Paciente'),
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
              onPressed: _savePatient,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo *',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator.validateName,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => FormValidator.validateRequired(value, 'Endereço'),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => FormValidator.validateRequired(value, 'Bairro'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => FormValidator.validateRequired(value, 'Cidade'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'Estado *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => FormValidator.validateRequired(value, 'Estado'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP *',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormValidator.validateCEP,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => FormValidator.validateRequired(value, 'Data de Nascimento'),
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: const InputDecoration(
                  labelText: 'Sexo *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(
                  labelText: 'Profissão *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => FormValidator.validateRequired(value, 'Profissão'),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (WhatsApp) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: FormValidator.validatePhone,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.patient == null ? 'Cadastrar Paciente' : 'Salvar Alterações',
                      style: const TextStyle(fontSize: 16),
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