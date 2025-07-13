class GeneralData {
  final String chiefComplaint;
  final String podiatristFrequency;
  final bool medications;
  final String medicationDetails;
  final bool allergies;
  final String allergyDetails;
  final String workPosition;
  final bool insoles;
  final bool smoking;
  final bool pregnant;
  final bool breastfeeding;
  final bool physicalActivity;
  final String physicalActivityFrequency;
  final String footwearType;
  final String dailyFootwearType;

  GeneralData({
    required this.chiefComplaint,
    required this.podiatristFrequency,
    required this.medications,
    required this.medicationDetails,
    required this.allergies,
    required this.allergyDetails,
    required this.workPosition,
    required this.insoles,
    required this.smoking,
    required this.pregnant,
    required this.breastfeeding,
    required this.physicalActivity,
    required this.physicalActivityFrequency,
    required this.footwearType,
    required this.dailyFootwearType,
  });

  Map<String, dynamic> toMap() {
    return {
      'chief_complaint': chiefComplaint,
      'podiatrist_frequency': podiatristFrequency,
      'medications': medications,
      'medication_details': medicationDetails,
      'allergies': allergies,
      'allergy_details': allergyDetails,
      'work_position': workPosition,
      'insoles': insoles,
      'smoking': smoking,
      'pregnant': pregnant,
      'breastfeeding': breastfeeding,
      'physical_activity': physicalActivity,
      'physical_activity_frequency': physicalActivityFrequency,
      'footwear_type': footwearType,
      'daily_footwear_type': dailyFootwearType,
    };
  }

  factory GeneralData.fromMap(Map<String, dynamic> map) {
    return GeneralData(
      chiefComplaint: map['chief_complaint'] ?? '',
      podiatristFrequency: map['podiatrist_frequency'] ?? '',
      medications: map['medications'] ?? false,
      medicationDetails: map['medication_details'] ?? '',
      allergies: map['allergies'] ?? false,
      allergyDetails: map['allergy_details'] ?? '',
      workPosition: map['work_position'] ?? '',
      insoles: map['insoles'] ?? false,
      smoking: map['smoking'] ?? false,
      pregnant: map['pregnant'] ?? false,
      breastfeeding: map['breastfeeding'] ?? false,
      physicalActivity: map['physical_activity'] ?? false,
      physicalActivityFrequency: map['physical_activity_frequency'] ?? '',
      footwearType: map['footwear_type'] ?? '',
      dailyFootwearType: map['daily_footwear_type'] ?? '',
    );
  }
}

class ClinicalData {
  // Medical conditions
  final bool gestante;
  final bool osteoporose;
  final bool cardiopatia;
  final bool marcaPasso;
  final bool hipertireoidismo;
  final bool hipotireoidismo;
  final bool hipertensao;
  final bool hipotensao;
  final bool renal;
  final bool neuropatia;
  final bool reumatismo;
  final bool quimioterapiaRadioterapia;
  final bool antecedentesOncologicos;
  final bool cirurgiaMmii;
  final bool alteracoesComprometimentoVasculares;
  
  // Diabetes related
  final bool diabetes;
  final String diabetesType;
  final String glucoseLevel;
  final String lastVerificationDate;
  
  // Insulin related
  final bool insulin;
  final String insulinType;
  
  // Diet related
  final bool diet;
  final String dietType;

  ClinicalData({
    this.gestante = false,
    this.osteoporose = false,
    this.cardiopatia = false,
    this.marcaPasso = false,
    this.hipertireoidismo = false,
    this.hipotireoidismo = false,
    this.hipertensao = false,
    this.hipotensao = false,
    this.renal = false,
    this.neuropatia = false,
    this.reumatismo = false,
    this.quimioterapiaRadioterapia = false,
    this.antecedentesOncologicos = false,
    this.cirurgiaMmii = false,
    this.alteracoesComprometimentoVasculares = false,
    this.diabetes = false,
    this.diabetesType = '',
    this.glucoseLevel = '',
    this.lastVerificationDate = '',
    this.insulin = false,
    this.insulinType = '',
    this.diet = false,
    this.dietType = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'gestante': gestante,
      'osteoporose': osteoporose,
      'cardiopatia': cardiopatia,
      'marca_passo': marcaPasso,
      'hipertireoidismo': hipertireoidismo,
      'hipotireoidismo': hipotireoidismo,
      'hipertensao': hipertensao,
      'hipotensao': hipotensao,
      'renal': renal,
      'neuropatia': neuropatia,
      'reumatismo': reumatismo,
      'quimioterapia_radioterapia': quimioterapiaRadioterapia,
      'antecedentes_oncologicos': antecedentesOncologicos,
      'cirurgia_mmii': cirurgiaMmii,
      'alteracoes_comprometimento_vasculares': alteracoesComprometimentoVasculares,
      'diabetes': diabetes,
      'diabetes_type': diabetesType,
      'glucose_level': glucoseLevel,
      'last_verification_date': lastVerificationDate,
      'insulin': insulin,
      'insulin_type': insulinType,
      'diet': diet,
      'diet_type': dietType,
    };
  }

  factory ClinicalData.fromMap(Map<String, dynamic> map) {
    return ClinicalData(
      gestante: map['gestante'] ?? false,
      osteoporose: map['osteoporose'] ?? false,
      cardiopatia: map['cardiopatia'] ?? false,
      marcaPasso: map['marca_passo'] ?? false,
      hipertireoidismo: map['hipertireoidismo'] ?? false,
      hipotireoidismo: map['hipotireoidismo'] ?? false,
      hipertensao: map['hipertensao'] ?? false,
      hipotensao: map['hipotensao'] ?? false,
      renal: map['renal'] ?? false,
      neuropatia: map['neuropatia'] ?? false,
      reumatismo: map['reumatismo'] ?? false,
      quimioterapiaRadioterapia: map['quimioterapia_radioterapia'] ?? false,
      antecedentesOncologicos: map['antecedentes_oncologicos'] ?? false,
      cirurgiaMmii: map['cirurgia_mmii'] ?? false,
      alteracoesComprometimentoVasculares: map['alteracoes_comprometimento_vasculares'] ?? false,
      diabetes: map['diabetes'] ?? false,
      diabetesType: map['diabetes_type'] ?? '',
      glucoseLevel: map['glucose_level'] ?? '',
      lastVerificationDate: map['last_verification_date'] ?? '',
      insulin: map['insulin'] ?? false,
      insulinType: map['insulin_type'] ?? '',
      diet: map['diet'] ?? false,
      dietType: map['diet_type'] ?? '',
    );
  }
}

class ResponsibilityTerm {
  final String patientName;
  final String rg;
  final String cpf;
  final String signature; // base64 encoded signature image
  final String date;

  ResponsibilityTerm({
    required this.patientName,
    required this.rg,
    required this.cpf,
    required this.signature,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'patient_name': patientName,
      'rg': rg,
      'cpf': cpf,
      'signature': signature,
      'date': date,
    };
  }

  factory ResponsibilityTerm.fromMap(Map<String, dynamic> map) {
    return ResponsibilityTerm(
      patientName: map['patient_name'] ?? '',
      rg: map['rg'] ?? '',
      cpf: map['cpf'] ?? '',
      signature: map['signature'] ?? '',
      date: map['date'] ?? '',
    );
  }
}

class Anamnesis {
  final String id;
  final String patientId;
  final GeneralData generalData;
  final ClinicalData clinicalData;
  final ResponsibilityTerm responsibilityTerm;
  final String observations;
  final DateTime createdAt;
  final DateTime updatedAt;

  Anamnesis({
    required this.id,
    required this.patientId,
    required this.generalData,
    required this.clinicalData,
    required this.responsibilityTerm,
    required this.observations,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'general_data': generalData.toMap(),
      'clinical_data': clinicalData.toMap(),
      'responsibility_term': responsibilityTerm.toMap(),
      'observations': observations,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Anamnesis.fromMap(Map<String, dynamic> map) {
    return Anamnesis(
      id: map['id'] ?? '',
      patientId: map['patient_id'] ?? '',
      generalData: GeneralData.fromMap(map['general_data'] ?? {}),
      clinicalData: ClinicalData.fromMap(map['clinical_data'] ?? {}),
      responsibilityTerm: ResponsibilityTerm.fromMap(map['responsibility_term'] ?? {}),
      observations: map['observations'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}