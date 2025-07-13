import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/anamnesis.dart';
import '../models/appointment.dart';
import '../utils/validators.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'podologia_app.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create patients table
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        neighborhood TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        cep TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        sex TEXT NOT NULL,
        profession TEXT NOT NULL,
        contact TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create anamnesis table
    await db.execute('''
      CREATE TABLE anamnesis (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        general_data TEXT NOT NULL,
        clinical_data TEXT NOT NULL,
        responsibility_term TEXT NOT NULL,
        observations TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // Create appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        appointment_id TEXT NOT NULL,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        patient_contact TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        appointment_date TEXT NOT NULL,
        appointment_time TEXT NOT NULL,
        message TEXT NOT NULL,
        sent INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (appointment_id) REFERENCES appointments (id),
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');
  }

  // Patient CRUD operations
  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patients');
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<Patient?> getPatientById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Patient>> searchPatients(String searchTerm) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'name LIKE ? OR contact LIKE ? OR birth_date LIKE ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%', '%$searchTerm%'],
    );
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(String id) async {
    final db = await database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Anamnesis CRUD operations
  Future<int> insertAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final Map<String, dynamic> anamnesisMap = anamnesis.toMap();
    
    // Convert complex objects to JSON strings for storage
    anamnesisMap['general_data'] = _convertToJson(anamnesisMap['general_data']);
    anamnesisMap['clinical_data'] = _convertToJson(anamnesisMap['clinical_data']);
    anamnesisMap['responsibility_term'] = _convertToJson(anamnesisMap['responsibility_term']);
    
    return await db.insert('anamnesis', anamnesisMap);
  }

  Future<List<Anamnesis>> getAllAnamnesis() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('anamnesis');
    return List.generate(maps.length, (i) => _anamnesisFromMap(maps[i]));
  }

  Future<List<Anamnesis>> getAnamnesisByPatientId(String patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'anamnesis',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) => _anamnesisFromMap(maps[i]));
  }

  Future<Anamnesis?> getAnamnesisById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'anamnesis',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _anamnesisFromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final Map<String, dynamic> anamnesisMap = anamnesis.toMap();
    
    // Convert complex objects to JSON strings for storage
    anamnesisMap['general_data'] = _convertToJson(anamnesisMap['general_data']);
    anamnesisMap['clinical_data'] = _convertToJson(anamnesisMap['clinical_data']);
    anamnesisMap['responsibility_term'] = _convertToJson(anamnesisMap['responsibility_term']);
    
    return await db.update(
      'anamnesis',
      anamnesisMap,
      where: 'id = ?',
      whereArgs: [anamnesis.id],
    );
  }

  Future<int> deleteAnamnesis(String id) async {
    final db = await database;
    return await db.delete(
      'anamnesis',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointment CRUD operations
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appointments');
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByPatientId(String patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(String id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Notification CRUD operations
  Future<int> insertNotification(NotificationModel notification) async {
    final db = await database;
    final Map<String, dynamic> notificationMap = notification.toMap();
    notificationMap['sent'] = notification.sent ? 1 : 0;
    return await db.insert('notifications', notificationMap);
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notifications');
    return List.generate(maps.length, (i) => _notificationFromMap(maps[i]));
  }

  Future<List<NotificationModel>> getPendingNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'sent = ? AND scheduled_time <= ?',
      whereArgs: [0, DateTime.now().toIso8601String()],
    );
    return List.generate(maps.length, (i) => _notificationFromMap(maps[i]));
  }

  Future<int> updateNotification(NotificationModel notification) async {
    final db = await database;
    final Map<String, dynamic> notificationMap = notification.toMap();
    notificationMap['sent'] = notification.sent ? 1 : 0;
    return await db.update(
      'notifications',
      notificationMap,
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  // Dashboard analytics
  Future<Map<String, int>> getMonthlyAppointmentStats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        substr(date, 1, 7) as month,
        COUNT(*) as count
      FROM appointments
      WHERE status = 'completed'
      GROUP BY substr(date, 1, 7)
      ORDER BY month
    ''');
    
    Map<String, int> stats = {};
    for (var map in maps) {
      stats[map['month']] = map['count'];
    }
    return stats;
  }

  Future<Map<String, int>> getDailyAppointmentStats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        CASE 
          WHEN substr(date, 9, 2) = '01' THEN 'Segunda'
          WHEN substr(date, 9, 2) = '02' THEN 'Terça'
          WHEN substr(date, 9, 2) = '03' THEN 'Quarta'
          WHEN substr(date, 9, 2) = '04' THEN 'Quinta'
          WHEN substr(date, 9, 2) = '05' THEN 'Sexta'
          WHEN substr(date, 9, 2) = '06' THEN 'Sábado'
          WHEN substr(date, 9, 2) = '07' THEN 'Domingo'
          ELSE 'Outro'
        END as day_of_week,
        COUNT(*) as count
      FROM appointments
      WHERE status = 'completed'
      GROUP BY day_of_week
      ORDER BY count DESC
    ''');
    
    Map<String, int> stats = {};
    for (var map in maps) {
      stats[map['day_of_week']] = map['count'];
    }
    return stats;
  }

  Future<int> getTotalAppointmentsThisMonth() async {
    final db = await database;
    final String currentMonth = DateTime.now().toIso8601String().substring(0, 7);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM appointments
      WHERE substr(date, 1, 7) = ? AND status = 'completed'
    ''', [currentMonth]);
    
    return maps.first['count'] ?? 0;
  }

  // Helper methods
  String _convertToJson(dynamic object) {
    try {
      return json.encode(object);
    } catch (e) {
      return object.toString();
    }
  }

  Anamnesis _anamnesisFromMap(Map<String, dynamic> map) {
    // Parse JSON strings back to objects
    final generalData = _parseJsonString(map['general_data']);
    final clinicalData = _parseJsonString(map['clinical_data']);
    final responsibilityTerm = _parseJsonString(map['responsibility_term']);
    
    return Anamnesis(
      id: map['id'],
      patientId: map['patient_id'],
      generalData: GeneralData.fromMap(generalData),
      clinicalData: ClinicalData.fromMap(clinicalData),
      responsibilityTerm: ResponsibilityTerm.fromMap(responsibilityTerm),
      observations: map['observations'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  NotificationModel _notificationFromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      appointmentId: map['appointment_id'],
      patientId: map['patient_id'],
      patientName: map['patient_name'],
      patientContact: map['patient_contact'],
      notificationType: map['notification_type'],
      scheduledTime: DateTime.parse(map['scheduled_time']),
      appointmentDate: map['appointment_date'],
      appointmentTime: map['appointment_time'],
      message: map['message'],
      sent: map['sent'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      return {};
    }
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}