import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/patient.dart';
import '../models/anamnesis.dart';
import '../services/database_service.dart';
import '../utils/validators.dart';
import '../utils/date_utils.dart' as date_utils;

class AnamnesisFormScreen extends StatefulWidget {
  final Patient patient;
  final Anamnesis? anamnesis;
  final bool isViewOnly;
  final bool isDuplicate;
  
  const AnamnesisFormScreen({
    super.key,
    required this.patient,
    this.anamnesis,
    this.isViewOnly = false,
    this.isDuplicate = false,
  });

  @override
  State<AnamnesisFormScreen> createState() => _AnamnesisFormScreenState();
}

class _AnamnesisFormScreenState extends State<AnamnesisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  // General Data Controllers
  final TextEditingController _chiefComplaintController = TextEditingController();
  final TextEditingController _podiatristFrequencyController = TextEditingController();
  final TextEditingController _medicationDetailsController = TextEditingController();
  final TextEditingController _allergyDetailsController = TextEditingController();
  final TextEditingController _workPositionController = TextEditingController();
  final TextEditingController _physicalActivityFrequencyController = TextEditingController();
  final TextEditingController _footwearTypeController = TextEditingController();
  final TextEditingController _dailyFootwearTypeController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  
  // Clinical Data Controllers
  final TextEditingController _diabetesTypeController = TextEditingController();
  final TextEditingController _glucoseLevelController = TextEditingController();
  final TextEditingController _lastVerificationDateController = TextEditingController();
  final TextEditingController _insulinTypeController = TextEditingController();
  final TextEditingController _dietTypeController = TextEditingController();
  
  // Responsibility Term Controllers
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _rgController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  // General Data Booleans
  bool _medications = false;
  bool _allergies = false;
  bool _insoles = false;
  bool _smoking = false;
  bool _pregnant = false;
  bool _breastfeeding = false;
  bool _physicalActivity = false;
  
  // Clinical Data Booleans
  bool _gestante = false;
  bool _osteoporose = false;
  bool _cardiopatia = false;
  bool _marcaPasso = false;
  bool _hipertireoidismo = false;
  bool _hipotireoidismo = false;
  bool _hipertensao = false;
  bool _hipotensao = false;
  bool _renal = false;
  bool _neuropatia = false;
  bool _reumatismo = false;
  bool _quimioterapiaRadioterapia = false;
  bool _antecedentesOncologicos = false;
  bool _cirurgiaMmii = false;
  bool _alteracoesComprometimentoVasculares = false;
  bool _diabetes = false;
  bool _insulin = false;
  bool _diet = false;
  
  String _insulinType = 'injectable';
  String _dietType = 'dietary';
  
  // Signature
  final GlobalKey<SignatureState> _signatureKey = GlobalKey<SignatureState>();
  String _signatureData = '';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.anamnesis != null) {
      final anamnesis = widget.anamnesis!;
      
      // General Data
      _chiefComplaintController.text = anamnesis.generalData.chiefComplaint;
      _podiatristFrequencyController.text = anamnesis.generalData.podiatristFrequency;
      _medicationDetailsController.text = anamnesis.generalData.medicationDetails;
      _allergyDetailsController.text = anamnesis.generalData.allergyDetails;
      _workPositionController.text = anamnesis.generalData.workPosition;
      _physicalActivityFrequencyController.text = anamnesis.generalData.physicalActivityFrequency;
      _footwearTypeController.text = anamnesis.generalData.footwearType;
      _dailyFootwearTypeController.text = anamnesis.generalData.dailyFootwearType;
      _observationsController.text = anamnesis.observations;
      
      _medications = anamnesis.generalData.medications;
      _allergies = anamnesis.generalData.allergies;
      _insoles = anamnesis.generalData.insoles;
      _smoking = anamnesis.generalData.smoking;
      _pregnant = anamnesis.generalData.pregnant;
      _breastfeeding = anamnesis.generalData.breastfeeding;
      _physicalActivity = anamnesis.generalData.physicalActivity;
      
      // Clinical Data
      _gestante = anamnesis.clinicalData.gestante;
      _osteoporose = anamnesis.clinicalData.osteoporose;
      _cardiopatia = anamnesis.clinicalData.cardiopatia;
      _marcaPasso = anamnesis.clinicalData.marcaPasso;
      _hipertireoidismo = anamnesis.clinicalData.hipertireoidismo;
      _hipotireoidismo = anamnesis.clinicalData.hipotireoidismo;
      _hipertensao = anamnesis.clinicalData.hipertensao;
      _hipotensao = anamnesis.clinicalData.hipotensao;
      _renal = anamnesis.clinicalData.renal;
      _neuropatia = anamnesis.clinicalData.neuropatia;
      _reumatismo = anamnesis.clinicalData.reumatismo;
      _quimioterapiaRadioterapia = anamnesis.clinicalData.quimioterapiaRadioterapia;
      _antecedentesOncologicos = anamnesis.clinicalData.antecedentesOncologicos;
      _cirurgiaMmii = anamnesis.clinicalData.cirurgiaMmii;
      _alteracoesComprometimentoVasculares = anamnesis.clinicalData.alteracoesComprometimentoVasculares;
      _diabetes = anamnesis.clinicalData.diabetes;
      _insulin = anamnesis.clinicalData.insulin;
      _diet = anamnesis.clinicalData.diet;
      
      _diabetesTypeController.text = anamnesis.clinicalData.diabetesType;
      _glucoseLevelController.text = anamnesis.clinicalData.glucoseLevel;
      _lastVerificationDateController.text = anamnesis.clinicalData.lastVerificationDate;
      _insulinTypeController.text = anamnesis.clinicalData.insulinType;
      _dietTypeController.text = anamnesis.clinicalData.dietType;
      
      // Responsibility Term
      _patientNameController.text = anamnesis.responsibilityTerm.patientName;
      _rgController.text = anamnesis.responsibilityTerm.rg;
      _cpfController.text = anamnesis.responsibilityTerm.cpf;
      _dateController.text = anamnesis.responsibilityTerm.date;
      _signatureData = anamnesis.responsibilityTerm.signature;
      
      if (widget.isDuplicate) {
        _patientNameController.text = widget.patient.name;
        _dateController.text = date_utils.DateUtils.formatDateForStorage(DateTime.now());
        _signatureData = '';
      }
    } else {
      // Initialize with patient data
      _patientNameController.text = widget.patient.name;
      _dateController.text = date_utils.DateUtils.formatDateForStorage(DateTime.now());
    }
  }

  Future<void> _saveAnamnesis() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_signatureData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assinatura é obrigatória')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final generalData = GeneralData(
        chiefComplaint: _chiefComplaintController.text,
        podiatristFrequency: _podiatristFrequencyController.text,
        medications: _medications,
        medicationDetails: _medicationDetailsController.text,
        allergies: _allergies,
        allergyDetails: _allergyDetailsController.text,
        workPosition: _workPositionController.text,
        insoles: _insoles,
        smoking: _smoking,
        pregnant: _pregnant,
        breastfeeding: _breastfeeding,
        physicalActivity: _physicalActivity,
        physicalActivityFrequency: _physicalActivityFrequencyController.text,
        footwearType: _footwearTypeController.text,
        dailyFootwearType: _dailyFootwearTypeController.text,
      );
      
      final clinicalData = ClinicalData(
        gestante: _gestante,
        osteoporose: _osteoporose,
        cardiopatia: _cardiopatia,
        marcaPasso: _marcaPasso,
        hipertireoidismo: _hipertireoidismo,
        hipotireoidismo: _hipotireoidismo,
        hipertensao: _hipertensao,
        hipotensao: _hipotensao,
        renal: _renal,
        neuropatia: _neuropatia,
        reumatismo: _reumatismo,
        quimioterapiaRadioterapia: _quimioterapiaRadioterapia,
        antecedentesOncologicos: _antecedentesOncologicos,
        cirurgiaMmii: _cirurgiaMmii,
        alteracoesComprometimentoVasculares: _alteracoesComprometimentoVasculares,
        diabetes: _diabetes,
        diabetesType: _diabetesTypeController.text,
        glucoseLevel: _glucoseLevelController.text,
        lastVerificationDate: _lastVerificationDateController.text,
        insulin: _insulin,
        insulinType: _insulinTypeController.text,
        diet: _diet,
        dietType: _dietTypeController.text,
      );
      
      final responsibilityTerm = ResponsibilityTerm(
        patientName: _patientNameController.text,
        rg: _rgController.text,
        cpf: _cpfController.text,
        signature: _signatureData,
        date: _dateController.text,
      );
      
      final anamnesis = Anamnesis(
        id: widget.anamnesis?.id ?? IdGenerator.generateAnamnesisId(),
        patientId: widget.patient.id,
        generalData: generalData,
        clinicalData: clinicalData,
        responsibilityTerm: responsibilityTerm,
        observations: _observationsController.text,
        createdAt: widget.anamnesis?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.anamnesis == null || widget.isDuplicate) {
        await _databaseService.insertAnamnesis(anamnesis);
      } else {
        await _databaseService.updateAnamnesis(anamnesis);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anamnese salva com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar anamnese: $e')),
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

  void _captureSignature() async {
    final signature = _signatureKey.currentState;
    if (signature != null) {
      final data = await signature.getData();
      if (data.isNotEmpty) {
        setState(() {
          _signatureData = base64Encode(data.buffer.asUint8List());
        });
      }
    }
  }

  void _clearSignature() {
    final signature = _signatureKey.currentState;
    if (signature != null) {
      signature.clear();
      setState(() {
        _signatureData = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isViewOnly 
            ? 'Visualizar Anamnese' 
            : (widget.anamnesis == null || widget.isDuplicate) 
                ? 'Nova Anamnese' 
                : 'Editar Anamnese'),
        actions: [
          if (!widget.isViewOnly)
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
                onPressed: _saveAnamnesis,
              ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info
              _buildPatientInfo(),
              
              const SizedBox(height: 24),
              
              // General Data Section
              _buildGeneralDataSection(),
              
              const SizedBox(height: 24),
              
              // Clinical Data Section
              _buildClinicalDataSection(),
              
              const SizedBox(height: 24),
              
              // Observations Section
              _buildObservationsSection(),
              
              const SizedBox(height: 24),
              
              // Responsibility Term Section
              _buildResponsibilityTermSection(),
              
              const SizedBox(height: 32),
              
              // Save Button
              if (!widget.isViewOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAnamnesis,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Salvar Anamnese',
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

  Widget _buildPatientInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Paciente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2E7D32),
                  child: Text(
                    widget.patient.name.isNotEmpty 
                        ? widget.patient.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      TextFormatter.formatPhone(widget.patient.contact),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados Gerais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _chiefComplaintController,
              decoration: const InputDecoration(
                labelText: 'Queixa Principal',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _podiatristFrequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequência ao Podólogo',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            // Medications
            CheckboxListTile(
              title: const Text('Medicamentos'),
              value: _medications,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _medications = value ?? false;
                });
              },
            ),
            
            if (_medications)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _medicationDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Detalhes dos Medicamentos',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  enabled: !widget.isViewOnly,
                ),
              ),
            
            // Allergies
            CheckboxListTile(
              title: const Text('Alergias'),
              value: _allergies,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _allergies = value ?? false;
                });
              },
            ),
            
            if (_allergies)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _allergyDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Detalhes das Alergias',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  enabled: !widget.isViewOnly,
                ),
              ),
            
            TextFormField(
              controller: _workPositionController,
              decoration: const InputDecoration(
                labelText: 'Posição no Trabalho',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            // Boolean fields
            CheckboxListTile(
              title: const Text('Uso de Palmilhas'),
              value: _insoles,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _insoles = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Fumante'),
              value: _smoking,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _smoking = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Grávida'),
              value: _pregnant,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _pregnant = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Amamentando'),
              value: _breastfeeding,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _breastfeeding = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Atividade Física'),
              value: _physicalActivity,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _physicalActivity = value ?? false;
                });
              },
            ),
            
            if (_physicalActivity)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _physicalActivityFrequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequência da Atividade Física',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.isViewOnly,
                ),
              ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _footwearTypeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Calçado',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _dailyFootwearTypeController,
              decoration: const InputDecoration(
                labelText: 'Calçado Diário',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isViewOnly,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados Clínicos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Medical conditions
            CheckboxListTile(
              title: const Text('Gestante'),
              value: _gestante,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _gestante = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Osteoporose'),
              value: _osteoporose,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _osteoporose = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Cardiopatia'),
              value: _cardiopatia,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _cardiopatia = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Marca-passo'),
              value: _marcaPasso,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _marcaPasso = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Hipertireoidismo'),
              value: _hipertireoidismo,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _hipertireoidismo = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Hipotireoidismo'),
              value: _hipotireoidismo,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _hipotireoidismo = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Hipertensão'),
              value: _hipertensao,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _hipertensao = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Hipotensão'),
              value: _hipotensao,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _hipotensao = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Problemas Renais'),
              value: _renal,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _renal = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Neuropatia'),
              value: _neuropatia,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _neuropatia = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Reumatismo'),
              value: _reumatismo,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _reumatismo = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Quimioterapia/Radioterapia'),
              value: _quimioterapiaRadioterapia,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _quimioterapiaRadioterapia = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Antecedentes Oncológicos'),
              value: _antecedentesOncologicos,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _antecedentesOncologicos = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Cirurgia MMII'),
              value: _cirurgiaMmii,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _cirurgiaMmii = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Alterações/Comprometimento Vasculares'),
              value: _alteracoesComprometimentoVasculares,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _alteracoesComprometimentoVasculares = value ?? false;
                });
              },
            ),
            
            // Diabetes section
            CheckboxListTile(
              title: const Text('Diabetes'),
              value: _diabetes,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _diabetes = value ?? false;
                });
              },
            ),
            
            if (_diabetes) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _diabetesTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Diabetes',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.isViewOnly,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _glucoseLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Nível de Glicose',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.isViewOnly,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _lastVerificationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data da Última Verificação',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.isViewOnly,
                ),
              ),
            ],
            
            // Insulin section
            CheckboxListTile(
              title: const Text('Insulina'),
              value: _insulin,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _insulin = value ?? false;
                });
              },
            ),
            
            if (_insulin)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _insulinType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Insulina',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'injectable', child: Text('Injetável')),
                    DropdownMenuItem(value: 'oral', child: Text('Oral')),
                  ],
                  onChanged: widget.isViewOnly ? null : (value) {
                    setState(() {
                      _insulinType = value!;
                    });
                  },
                ),
              ),
            
            // Diet section
            CheckboxListTile(
              title: const Text('Dieta'),
              value: _diet,
              onChanged: widget.isViewOnly ? null : (value) {
                setState(() {
                  _diet = value ?? false;
                });
              },
            ),
            
            if (_diet)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextFormField(
                  controller: _dietTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Dieta',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.isViewOnly,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observações dos Procedimentos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
                hintText: 'Descreva os procedimentos realizados, observações importantes, etc.',
              ),
              maxLines: 5,
              enabled: !widget.isViewOnly,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsibilityTermSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Termo de Responsabilidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _patientNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Paciente',
                border: OutlineInputBorder(),
              ),
              validator: FormValidator.validateName,
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _rgController,
              decoration: const InputDecoration(
                labelText: 'RG',
                border: OutlineInputBorder(),
              ),
              validator: FormValidator.validateRG,
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
              validator: FormValidator.validateCPF,
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Data',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isViewOnly,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Assinatura Digital',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            if (!widget.isViewOnly) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  key: _signatureKey,
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                  strokeColor: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _captureSignature,
                    child: const Text('Capturar Assinatura'),
                  ),
                  ElevatedButton(
                    onPressed: _clearSignature,
                    child: const Text('Limpar'),
                  ),
                ],
              ),
            ] else if (_signatureData.isNotEmpty) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.memory(
                    base64Decode(_signatureData),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
            
            if (_signatureData.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '✓ Assinatura capturada',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}