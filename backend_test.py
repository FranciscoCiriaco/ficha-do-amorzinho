import requests
import json
import time
import unittest
from datetime import datetime, timedelta

# Get the backend URL from the frontend/.env file
BACKEND_URL = "https://a265bd68-87e1-47fc-8a06-2fa885ac2d71.preview.emergentagent.com/api"

class PodiatryBackendTest(unittest.TestCase):
    """Test suite for the Podiatry Management System Backend API"""
    
    def setUp(self):
        """Set up test data"""
        # Test patient data
        self.test_patient = {
            "name": "Maria Silva",
            "address": "Rua das Flores, 123",
            "neighborhood": "Jardim Primavera",
            "city": "São Paulo",
            "state": "SP",
            "cep": "01234-567",
            "birth_date": "1985-05-15",
            "sex": "Feminino",
            "profession": "Professora",
            "contact": "11987654321"
        }
        
        # Test anamnesis data
        self.test_anamnesis = {
            "patient_id": "",  # Will be filled after patient creation
            "general_data": {
                "chief_complaint": "Dor no calcanhar",
                "podiatrist_frequency": "Primeira vez",
                "medications": True,
                "medication_details": "Anti-inflamatórios",
                "allergies": False,
                "allergy_details": "",
                "work_position": "Sentada",
                "insoles": False,
                "smoking": False,
                "pregnant": False,
                "breastfeeding": False,
                "physical_activity": True,
                "physical_activity_frequency": "3 vezes por semana",
                "footwear_type": "Tênis",
                "daily_footwear_type": "Sapato social"
            },
            "clinical_data": {
                "gestante": False,
                "osteoporose": False,
                "cardiopatia": False,
                "marca_passo": False,
                "hipertireoidismo": False,
                "hipotireoidismo": True,
                "hipertensao": True,
                "hipotensao": False,
                "renal": False,
                "neuropatia": False,
                "reumatismo": False,
                "quimioterapia_radioterapia": False,
                "antecedentes_oncologicos": False,
                "cirurgia_mmii": False,
                "alteracoes_comprometimento_vasculares": False,
                "diabetes": True,
                "diabetes_type": "Tipo 2",
                "glucose_level": "120",
                "last_verification_date": "2023-01-15",
                "insulin": True,
                "insulin_type": "oral",
                "diet": True,
                "diet_type": "Baixo carboidrato"
            },
            "responsibility_term": {
                "patient_name": "Maria Silva",
                "rg": "12.345.678-9",
                "cpf": "123.456.789-00",
                "signature": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAADICAYAAADGFbfiAAAAAXNSR0IArs4c6QAAIABJREFUeF7t",
                "date": "2023-05-20"
            },
            "observations": "Procedimento realizado: Remoção de calos nos pés. Aplicação de tratamento hidratante. Orientações sobre cuidados diários."
        }
        
        # Test appointment data
        self.test_appointment = {
            "patient_id": "",  # Will be filled after patient creation
            "patient_name": "Maria Silva",
            "date": "2023-06-01",
            "time": "14:30"
        }
        
        # Store created resources for cleanup
        self.created_resources = {
            "patients": [],
            "anamnesis": [],
            "appointments": []
        }
    
    def tearDown(self):
        """Clean up created resources"""
        # Delete created appointments
        for appointment_id in self.created_resources["appointments"]:
            try:
                requests.delete(f"{BACKEND_URL}/appointments/{appointment_id}")
            except:
                pass
        
        # Delete created anamnesis forms
        for anamnesis_id in self.created_resources["anamnesis"]:
            try:
                requests.delete(f"{BACKEND_URL}/anamnesis/{anamnesis_id}")
            except:
                pass
        
        # Delete created patients
        for patient_id in self.created_resources["patients"]:
            try:
                requests.delete(f"{BACKEND_URL}/patients/{patient_id}")
            except:
                pass
    
    # Patient Management Tests
    def test_01_patient_crud_operations(self):
        """Test patient CRUD operations"""
        print("\n=== Testing Patient CRUD Operations ===")
        
        # Create patient
        print("Creating patient...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        print(f"Patient created with ID: {patient_id}")
        
        # Get all patients
        print("Getting all patients...")
        response = requests.get(f"{BACKEND_URL}/patients")
        self.assertEqual(response.status_code, 200, f"Failed to get patients: {response.text}")
        
        patients = response.json()
        self.assertIsInstance(patients, list, "Expected a list of patients")
        self.assertGreaterEqual(len(patients), 1, "Expected at least one patient")
        
        # Get specific patient
        print(f"Getting patient with ID: {patient_id}")
        response = requests.get(f"{BACKEND_URL}/patients/{patient_id}")
        self.assertEqual(response.status_code, 200, f"Failed to get patient: {response.text}")
        
        patient = response.json()
        self.assertEqual(patient["id"], patient_id, "Patient ID mismatch")
        self.assertEqual(patient["name"], self.test_patient["name"], "Patient name mismatch")
        
        # Update patient
        print(f"Updating patient with ID: {patient_id}")
        updated_patient = self.test_patient.copy()
        updated_patient["name"] = "Maria Silva Updated"
        updated_patient["contact"] = "11999999999"
        
        response = requests.put(f"{BACKEND_URL}/patients/{patient_id}", json=updated_patient)
        self.assertEqual(response.status_code, 200, f"Failed to update patient: {response.text}")
        
        updated_patient_data = response.json()
        self.assertEqual(updated_patient_data["name"], "Maria Silva Updated", "Patient name not updated")
        self.assertEqual(updated_patient_data["contact"], "11999999999", "Patient contact not updated")
        
        # Delete patient (will be done in tearDown)
        print(f"Patient CRUD operations successful for ID: {patient_id}")
        
        return patient_id
    
    # Anamnesis Management Tests
    def test_02_anamnesis_operations(self):
        """Test anamnesis operations"""
        print("\n=== Testing Anamnesis Operations ===")
        
        # Create a patient first
        print("Creating patient for anamnesis test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Update anamnesis with patient ID
        self.test_anamnesis["patient_id"] = patient_id
        
        # Create anamnesis
        print("Creating anamnesis form...")
        response = requests.post(f"{BACKEND_URL}/anamnesis", json=self.test_anamnesis)
        self.assertEqual(response.status_code, 200, f"Failed to create anamnesis: {response.text}")
        
        anamnesis_data = response.json()
        anamnesis_id = anamnesis_data["id"]
        self.created_resources["anamnesis"].append(anamnesis_id)
        
        print(f"Anamnesis created with ID: {anamnesis_id}")
        
        # Get anamnesis for patient
        print(f"Getting anamnesis for patient ID: {patient_id}")
        response = requests.get(f"{BACKEND_URL}/anamnesis/{patient_id}")
        self.assertEqual(response.status_code, 200, f"Failed to get anamnesis for patient: {response.text}")
        
        anamnesis_list = response.json()
        self.assertIsInstance(anamnesis_list, list, "Expected a list of anamnesis forms")
        self.assertGreaterEqual(len(anamnesis_list), 1, "Expected at least one anamnesis form")
        
        # Get specific anamnesis form
        print(f"Getting anamnesis form with ID: {anamnesis_id}")
        response = requests.get(f"{BACKEND_URL}/anamnesis/form/{anamnesis_id}")
        self.assertEqual(response.status_code, 200, f"Failed to get anamnesis form: {response.text}")
        
        anamnesis = response.json()
        self.assertEqual(anamnesis["id"], anamnesis_id, "Anamnesis ID mismatch")
        self.assertEqual(anamnesis["patient_id"], patient_id, "Patient ID mismatch in anamnesis")
        
        # Update anamnesis
        print(f"Updating anamnesis with ID: {anamnesis_id}")
        updated_anamnesis = self.test_anamnesis.copy()
        updated_anamnesis["general_data"]["chief_complaint"] = "Dor no tornozelo"
        updated_anamnesis["clinical_data"]["diabetes"] = False
        
        response = requests.put(f"{BACKEND_URL}/anamnesis/{anamnesis_id}", json=updated_anamnesis)
        self.assertEqual(response.status_code, 200, f"Failed to update anamnesis: {response.text}")
        
        updated_anamnesis_data = response.json()
        self.assertEqual(updated_anamnesis_data["general_data"]["chief_complaint"], "Dor no tornozelo", "Anamnesis chief complaint not updated")
        self.assertEqual(updated_anamnesis_data["clinical_data"]["diabetes"], False, "Anamnesis diabetes status not updated")
        
        print(f"Anamnesis operations successful for ID: {anamnesis_id}")
        
        return patient_id, anamnesis_id
    
    # Appointment Management Tests
    def test_03_appointment_operations(self):
        """Test appointment operations"""
        print("\n=== Testing Appointment Operations ===")
        
        # Create a patient first
        print("Creating patient for appointment test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Update appointment with patient ID
        self.test_appointment["patient_id"] = patient_id
        
        # Create appointment
        print("Creating appointment...")
        response = requests.post(f"{BACKEND_URL}/appointments", json=self.test_appointment)
        self.assertEqual(response.status_code, 200, f"Failed to create appointment: {response.text}")
        
        appointment_data = response.json()
        appointment_id = appointment_data["id"]
        self.created_resources["appointments"].append(appointment_id)
        
        print(f"Appointment created with ID: {appointment_id}")
        
        # Get all appointments
        print("Getting all appointments...")
        response = requests.get(f"{BACKEND_URL}/appointments")
        self.assertEqual(response.status_code, 200, f"Failed to get appointments: {response.text}")
        
        appointments = response.json()
        self.assertIsInstance(appointments, list, "Expected a list of appointments")
        self.assertGreaterEqual(len(appointments), 1, "Expected at least one appointment")
        
        # Get appointments for patient
        print(f"Getting appointments for patient ID: {patient_id}")
        response = requests.get(f"{BACKEND_URL}/appointments/{patient_id}")
        self.assertEqual(response.status_code, 200, f"Failed to get appointments for patient: {response.text}")
        
        patient_appointments = response.json()
        self.assertIsInstance(patient_appointments, list, "Expected a list of appointments")
        self.assertGreaterEqual(len(patient_appointments), 1, "Expected at least one appointment for patient")
        
        print(f"Appointment operations successful for ID: {appointment_id}")
        
        return patient_id, appointment_id
    
    # Search Tests
    def test_04_search_functionality(self):
        """Test search functionality"""
        print("\n=== Testing Search Functionality ===")
        
        # Create a patient with unique name for search
        unique_patient = self.test_patient.copy()
        unique_patient["name"] = f"UniqueTestPatient{int(time.time())}"
        
        print(f"Creating patient with unique name: {unique_patient['name']}")
        response = requests.post(f"{BACKEND_URL}/patients", json=unique_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Wait a moment for the database to update
        time.sleep(1)
        
        # Search by name
        search_term = unique_patient["name"][:10]  # Use part of the name
        print(f"Searching for patients with term: {search_term}")
        response = requests.get(f"{BACKEND_URL}/search/patients?q={search_term}")
        self.assertEqual(response.status_code, 200, f"Failed to search patients: {response.text}")
        
        search_results = response.json()
        self.assertIsInstance(search_results, list, "Expected a list of search results")
        self.assertGreaterEqual(len(search_results), 1, "Expected at least one search result")
        
        # Verify the unique patient is in the results
        found = False
        for patient in search_results:
            if patient["id"] == patient_id:
                found = True
                break
        
        self.assertTrue(found, f"Could not find patient with ID {patient_id} in search results")
        
        print(f"Search functionality successful for term: {search_term}")
        
        return patient_id

    # Error Handling Tests
    def test_05_error_handling(self):
        """Test error handling"""
        print("\n=== Testing Error Handling ===")
        
        # Test getting non-existent patient
        print("Testing get non-existent patient...")
        non_existent_id = "00000000-0000-0000-0000-000000000000"
        response = requests.get(f"{BACKEND_URL}/patients/{non_existent_id}")
        self.assertEqual(response.status_code, 404, f"Expected 404 for non-existent patient, got: {response.status_code}")
        
        # Test updating non-existent patient
        print("Testing update non-existent patient...")
        response = requests.put(f"{BACKEND_URL}/patients/{non_existent_id}", json=self.test_patient)
        self.assertEqual(response.status_code, 404, f"Expected 404 for updating non-existent patient, got: {response.status_code}")
        
        # Test deleting non-existent patient
        print("Testing delete non-existent patient...")
        response = requests.delete(f"{BACKEND_URL}/patients/{non_existent_id}")
        self.assertEqual(response.status_code, 404, f"Expected 404 for deleting non-existent patient, got: {response.status_code}")
        
        # Test getting non-existent anamnesis
        print("Testing get non-existent anamnesis...")
        response = requests.get(f"{BACKEND_URL}/anamnesis/form/{non_existent_id}")
        self.assertEqual(response.status_code, 404, f"Expected 404 for non-existent anamnesis, got: {response.status_code}")
        
        print("Error handling tests successful")

    # Anamnesis with Observations Tests
    def test_06_anamnesis_with_observations(self):
        """Test anamnesis with observations field"""
        print("\n=== Testing Anamnesis with Observations Field ===")
        
        # Create a patient first
        print("Creating patient for anamnesis observations test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Update anamnesis with patient ID
        self.test_anamnesis["patient_id"] = patient_id
        
        # Create anamnesis with observations
        print("Creating anamnesis form with observations...")
        response = requests.post(f"{BACKEND_URL}/anamnesis", json=self.test_anamnesis)
        self.assertEqual(response.status_code, 200, f"Failed to create anamnesis: {response.text}")
        
        anamnesis_data = response.json()
        anamnesis_id = anamnesis_data["id"]
        self.created_resources["anamnesis"].append(anamnesis_id)
        
        print(f"Anamnesis created with ID: {anamnesis_id}")
        
        # Verify observations field is present and correct
        self.assertIn("observations", anamnesis_data, "Observations field not present in created anamnesis")
        self.assertEqual(anamnesis_data["observations"], self.test_anamnesis["observations"], 
                         "Observations field value does not match expected value")
        
        # Get specific anamnesis form and verify observations
        print(f"Getting anamnesis form with ID: {anamnesis_id} to verify observations...")
        response = requests.get(f"{BACKEND_URL}/anamnesis/form/{anamnesis_id}")
        self.assertEqual(response.status_code, 200, f"Failed to get anamnesis form: {response.text}")
        
        anamnesis = response.json()
        self.assertIn("observations", anamnesis, "Observations field not present in retrieved anamnesis")
        self.assertEqual(anamnesis["observations"], self.test_anamnesis["observations"], 
                         "Observations field value does not match expected value in retrieved anamnesis")
        
        # Update anamnesis with new observations
        print(f"Updating anamnesis with new observations...")
        updated_anamnesis = self.test_anamnesis.copy()
        updated_anamnesis["observations"] = "Procedimento atualizado: Remoção de calos nos pés e unhas encravadas. Aplicação de tratamento hidratante especial. Orientações detalhadas sobre cuidados diários e uso de calçados adequados."
        
        response = requests.put(f"{BACKEND_URL}/anamnesis/{anamnesis_id}", json=updated_anamnesis)
        self.assertEqual(response.status_code, 200, f"Failed to update anamnesis: {response.text}")
        
        updated_anamnesis_data = response.json()
        self.assertIn("observations", updated_anamnesis_data, "Observations field not present in updated anamnesis")
        self.assertEqual(updated_anamnesis_data["observations"], updated_anamnesis["observations"], 
                         "Updated observations field value does not match expected value")
        
        # Get anamnesis for patient and verify observations in list
        print(f"Getting anamnesis list for patient ID: {patient_id} to verify observations...")
        response = requests.get(f"{BACKEND_URL}/anamnesis/{patient_id}")
        self.assertEqual(response.status_code, 200, f"Failed to get anamnesis for patient: {response.text}")
        
        anamnesis_list = response.json()
        self.assertIsInstance(anamnesis_list, list, "Expected a list of anamnesis forms")
        self.assertGreaterEqual(len(anamnesis_list), 1, "Expected at least one anamnesis form")
        
        # Find our anamnesis in the list
        found = False
        for anamnesis_item in anamnesis_list:
            if anamnesis_item["id"] == anamnesis_id:
                found = True
                self.assertIn("observations", anamnesis_item, "Observations field not present in anamnesis list item")
                self.assertEqual(anamnesis_item["observations"], updated_anamnesis["observations"], 
                                "Observations field value does not match expected value in anamnesis list item")
                break
        
        self.assertTrue(found, f"Could not find anamnesis with ID {anamnesis_id} in patient's anamnesis list")
        
        print(f"Anamnesis with observations tests successful for ID: {anamnesis_id}")
        
        return patient_id, anamnesis_id

    # WhatsApp Notification Tests
    def test_07_whatsapp_notification_creation(self):
        """Test WhatsApp notification creation when appointments are made"""
        print("\n=== Testing WhatsApp Notification Creation ===")
        
        # Create a patient first
        print("Creating patient for notification test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Create an appointment for tomorrow
        tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
        appointment_time = "14:00"
        
        tomorrow_appointment = {
            "patient_id": patient_id,
            "patient_name": self.test_patient["name"],
            "date": tomorrow,
            "time": appointment_time
        }
        
        print(f"Creating appointment for tomorrow ({tomorrow}) at {appointment_time}...")
        response = requests.post(f"{BACKEND_URL}/appointments", json=tomorrow_appointment)
        self.assertEqual(response.status_code, 200, f"Failed to create appointment: {response.text}")
        
        appointment_data = response.json()
        appointment_id = appointment_data["id"]
        self.created_resources["appointments"].append(appointment_id)
        
        # Get all notifications
        print("Getting all notifications...")
        response = requests.get(f"{BACKEND_URL}/notifications")
        self.assertEqual(response.status_code, 200, f"Failed to get notifications: {response.text}")
        
        notifications = response.json()
        self.assertIsInstance(notifications, list, "Expected a list of notifications")
        
        # Filter notifications for our appointment
        appointment_notifications = [n for n in notifications if n["appointment_id"] == appointment_id]
        
        # Verify that both notification types were created
        self.assertEqual(len(appointment_notifications), 2, 
                         f"Expected 2 notifications for appointment, got {len(appointment_notifications)}")
        
        notification_types = [n["notification_type"] for n in appointment_notifications]
        self.assertIn("1_day_before", notification_types, "1_day_before notification not created")
        self.assertIn("1_hour_30_before", notification_types, "1_hour_30_before notification not created")
        
        # Verify notification content
        for notification in appointment_notifications:
            self.assertEqual(notification["patient_id"], patient_id, "Patient ID mismatch in notification")
            self.assertEqual(notification["patient_name"], self.test_patient["name"], "Patient name mismatch in notification")
            self.assertEqual(notification["patient_contact"], self.test_patient["contact"], "Patient contact mismatch in notification")
            self.assertEqual(notification["appointment_date"], tomorrow, "Appointment date mismatch in notification")
            self.assertEqual(notification["appointment_time"], appointment_time, "Appointment time mismatch in notification")
            self.assertFalse(notification["sent"], "Notification should not be marked as sent initially")
            
            # Verify message content
            self.assertIn(self.test_patient["name"], notification["message"], "Patient name not found in message")
            
            # Check for date in Brazilian format (convert YYYY-MM-DD to DD/MM/YYYY)
            date_parts = tomorrow.split("-")
            brazilian_date = f"{date_parts[2]}/{date_parts[1]}/{date_parts[0]}"
            self.assertIn(brazilian_date, notification["message"], "Formatted date not found in message")
            
            self.assertIn(appointment_time, notification["message"], "Appointment time not found in message")
            
            # Verify specific content based on notification type
            if notification["notification_type"] == "1_day_before":
                self.assertIn("amanhã", notification["message"], "Expected 'amanhã' in 1_day_before message")
                self.assertIn("CONFIRMO", notification["message"], "Expected 'CONFIRMO' in 1_day_before message")
            else:  # 1_hour_30_before
                self.assertIn("1h30", notification["message"], "Expected '1h30' in 1_hour_30_before message")
                self.assertIn("A CAMINHO", notification["message"], "Expected 'A CAMINHO' in 1_hour_30_before message")
        
        print(f"WhatsApp notification creation successful for appointment ID: {appointment_id}")
        
        return patient_id, appointment_id, appointment_notifications

    def test_08_notification_endpoints(self):
        """Test notification endpoints"""
        print("\n=== Testing Notification Endpoints ===")
        
        # Create a patient and appointment first to generate notifications
        print("Creating patient and appointment for notification endpoints test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Create an appointment for today + 2 hours (to test 1h30 before notification)
        now = datetime.now()
        appointment_date = now.strftime("%Y-%m-%d")
        appointment_time = (now + timedelta(hours=2)).strftime("%H:%M")
        
        appointment = {
            "patient_id": patient_id,
            "patient_name": self.test_patient["name"],
            "date": appointment_date,
            "time": appointment_time
        }
        
        print(f"Creating appointment for today ({appointment_date}) at {appointment_time}...")
        response = requests.post(f"{BACKEND_URL}/appointments", json=appointment)
        self.assertEqual(response.status_code, 200, f"Failed to create appointment: {response.text}")
        
        appointment_data = response.json()
        appointment_id = appointment_data["id"]
        self.created_resources["appointments"].append(appointment_id)
        
        # 1. Test GET /api/notifications
        print("Testing GET /api/notifications endpoint...")
        response = requests.get(f"{BACKEND_URL}/notifications")
        self.assertEqual(response.status_code, 200, f"Failed to get notifications: {response.text}")
        
        notifications = response.json()
        self.assertIsInstance(notifications, list, "Expected a list of notifications")
        
        # Filter notifications for our appointment
        appointment_notifications = [n for n in notifications if n["appointment_id"] == appointment_id]
        self.assertEqual(len(appointment_notifications), 2, 
                         f"Expected 2 notifications for appointment, got {len(appointment_notifications)}")
        
        # Store notification IDs for later tests
        notification_ids = [n["id"] for n in appointment_notifications]
        
        # 2. Test GET /api/notifications/pending
        print("Testing GET /api/notifications/pending endpoint...")
        response = requests.get(f"{BACKEND_URL}/notifications/pending")
        self.assertEqual(response.status_code, 200, f"Failed to get pending notifications: {response.text}")
        
        pending_notifications = response.json()
        self.assertIsInstance(pending_notifications, list, "Expected a list of pending notifications")
        
        # The 1h30 before notification should be pending if we're within 1h30 of the appointment
        # But this depends on timing, so we'll just check the structure
        if pending_notifications:
            pending = pending_notifications[0]
            self.assertIn("id", pending, "Expected 'id' field in pending notification")
            self.assertIn("patient_name", pending, "Expected 'patient_name' field in pending notification")
            self.assertIn("patient_contact", pending, "Expected 'patient_contact' field in pending notification")
            self.assertIn("notification_type", pending, "Expected 'notification_type' field in pending notification")
            self.assertIn("appointment_date", pending, "Expected 'appointment_date' field in pending notification")
            self.assertIn("appointment_time", pending, "Expected 'appointment_time' field in pending notification")
            self.assertIn("message", pending, "Expected 'message' field in pending notification")
            self.assertIn("whatsapp_link", pending, "Expected 'whatsapp_link' field in pending notification")
            self.assertIn("scheduled_time", pending, "Expected 'scheduled_time' field in pending notification")
        
        # 3. Test GET /api/notifications/upcoming
        print("Testing GET /api/notifications/upcoming endpoint...")
        response = requests.get(f"{BACKEND_URL}/notifications/upcoming")
        self.assertEqual(response.status_code, 200, f"Failed to get upcoming notifications: {response.text}")
        
        upcoming_notifications = response.json()
        self.assertIsInstance(upcoming_notifications, list, "Expected a list of upcoming notifications")
        
        # At least one of our notifications should be upcoming
        if upcoming_notifications:
            upcoming = upcoming_notifications[0]
            self.assertIn("id", upcoming, "Expected 'id' field in upcoming notification")
            self.assertIn("patient_name", upcoming, "Expected 'patient_name' field in upcoming notification")
            self.assertIn("patient_contact", upcoming, "Expected 'patient_contact' field in upcoming notification")
            self.assertIn("notification_type", upcoming, "Expected 'notification_type' field in upcoming notification")
            self.assertIn("appointment_date", upcoming, "Expected 'appointment_date' field in upcoming notification")
            self.assertIn("appointment_time", upcoming, "Expected 'appointment_time' field in upcoming notification")
            self.assertIn("message", upcoming, "Expected 'message' field in upcoming notification")
            self.assertIn("whatsapp_link", upcoming, "Expected 'whatsapp_link' field in upcoming notification")
            self.assertIn("scheduled_time", upcoming, "Expected 'scheduled_time' field in upcoming notification")
            self.assertIn("time_until_send", upcoming, "Expected 'time_until_send' field in upcoming notification")
        
        # 4. Test POST /api/notifications/{id}/mark-sent
        if notification_ids:
            print(f"Testing POST /api/notifications/{notification_ids[0]}/mark-sent endpoint...")
            response = requests.post(f"{BACKEND_URL}/notifications/{notification_ids[0]}/mark-sent")
            self.assertEqual(response.status_code, 200, f"Failed to mark notification as sent: {response.text}")
            
            # Verify notification is marked as sent
            response = requests.get(f"{BACKEND_URL}/notifications")
            notifications = response.json()
            marked_notification = next((n for n in notifications if n["id"] == notification_ids[0]), None)
            
            self.assertIsNotNone(marked_notification, f"Could not find notification with ID {notification_ids[0]}")
            self.assertTrue(marked_notification["sent"], "Notification should be marked as sent")
        
        print(f"Notification endpoints tests successful")
        
        return patient_id, appointment_id, notification_ids

    def test_09_whatsapp_message_generation(self):
        """Test WhatsApp message generation"""
        print("\n=== Testing WhatsApp Message Generation ===")
        
        # Create a patient first
        print("Creating patient for WhatsApp message test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Create two appointments with different dates/times
        tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
        
        appointments = [
            {
                "patient_id": patient_id,
                "patient_name": self.test_patient["name"],
                "date": tomorrow,
                "time": "09:30"
            },
            {
                "patient_id": patient_id,
                "patient_name": self.test_patient["name"],
                "date": tomorrow,
                "time": "15:45"
            }
        ]
        
        appointment_ids = []
        for i, appointment in enumerate(appointments):
            print(f"Creating appointment {i+1} for {appointment['date']} at {appointment['time']}...")
            response = requests.post(f"{BACKEND_URL}/appointments", json=appointment)
            self.assertEqual(response.status_code, 200, f"Failed to create appointment: {response.text}")
            
            appointment_data = response.json()
            appointment_id = appointment_data["id"]
            appointment_ids.append(appointment_id)
            self.created_resources["appointments"].append(appointment_id)
        
        # Get all notifications
        print("Getting all notifications to check message generation...")
        response = requests.get(f"{BACKEND_URL}/notifications")
        self.assertEqual(response.status_code, 200, f"Failed to get notifications: {response.text}")
        
        notifications = response.json()
        
        # Filter notifications for our appointments
        appointment_notifications = [n for n in notifications if n["appointment_id"] in appointment_ids]
        
        # We should have 4 notifications (2 per appointment)
        self.assertEqual(len(appointment_notifications), 4, 
                         f"Expected 4 notifications for 2 appointments, got {len(appointment_notifications)}")
        
        # Check WhatsApp message formatting for each notification
        for notification in appointment_notifications:
            # Basic message structure checks
            self.assertIn("🦶", notification["message"], "Expected podiatry emoji in message")
            self.assertIn("Podologia", notification["message"], "Expected 'Podologia' in message")
            self.assertIn(self.test_patient["name"], notification["message"], "Patient name not found in message")
            
            # Convert YYYY-MM-DD to DD/MM/YYYY for Brazilian format
            date_parts = notification["appointment_date"].split("-")
            brazilian_date = f"{date_parts[2]}/{date_parts[1]}/{date_parts[0]}"
            self.assertIn(brazilian_date, notification["message"], "Formatted date not found in message")
            
            self.assertIn(notification["appointment_time"], notification["message"], "Appointment time not found in message")
            
            # Check notification type specific content
            if notification["notification_type"] == "1_day_before":
                self.assertIn("amanhã", notification["message"], "Expected 'amanhã' in 1_day_before message")
                self.assertIn("CONFIRMO", notification["message"], "Expected 'CONFIRMO' in 1_day_before message")
                self.assertIn("CANCELAR", notification["message"], "Expected 'CANCELAR' in 1_day_before message")
            else:  # 1_hour_30_before
                self.assertIn("1h30", notification["message"], "Expected '1h30' in 1_hour_30_before message")
                self.assertIn("A CAMINHO", notification["message"], "Expected 'A CAMINHO' in 1_hour_30_before message")
                self.assertIn("ATRASO", notification["message"], "Expected 'ATRASO' in 1_hour_30_before message")
                self.assertIn("CANCELAR", notification["message"], "Expected 'CANCELAR' in 1_hour_30_before message")
        
        # Test WhatsApp link generation
        print("Testing WhatsApp link generation...")
        response = requests.get(f"{BACKEND_URL}/notifications/upcoming")
        self.assertEqual(response.status_code, 200, f"Failed to get upcoming notifications: {response.text}")
        
        upcoming_notifications = response.json()
        
        if upcoming_notifications:
            for notification in upcoming_notifications:
                # Check WhatsApp link format
                self.assertIn("whatsapp_link", notification, "WhatsApp link not found in notification")
                whatsapp_link = notification["whatsapp_link"]
                
                # Link should start with https://wa.me/
                self.assertTrue(whatsapp_link.startswith("https://wa.me/"), 
                               f"WhatsApp link should start with 'https://wa.me/', got: {whatsapp_link}")
                
                # Link should contain the patient's phone number with Brazil country code
                clean_phone = ''.join(filter(str.isdigit, self.test_patient["contact"]))
                if not clean_phone.startswith('55'):
                    clean_phone = '55' + clean_phone
                
                self.assertIn(clean_phone, whatsapp_link, 
                             f"WhatsApp link should contain patient's phone number {clean_phone}, got: {whatsapp_link}")
                
                # Link should contain the message as a URL parameter
                self.assertIn("?text=", whatsapp_link, "WhatsApp link should contain '?text=' parameter")
        
        print(f"WhatsApp message generation tests successful")
        
        return patient_id, appointment_ids

    def test_10_notification_scheduling(self):
        """Test notification scheduling"""
        print("\n=== Testing Notification Scheduling ===")
        
        # Create a patient first
        print("Creating patient for notification scheduling test...")
        response = requests.post(f"{BACKEND_URL}/patients", json=self.test_patient)
        self.assertEqual(response.status_code, 200, f"Failed to create patient: {response.text}")
        
        patient_data = response.json()
        patient_id = patient_data["id"]
        self.created_resources["patients"].append(patient_id)
        
        # Create appointments with different times to test scheduling
        now = datetime.now()
        tomorrow = (now + timedelta(days=1)).strftime("%Y-%m-%d")
        day_after_tomorrow = (now + timedelta(days=2)).strftime("%Y-%m-%d")
        
        appointments = [
            {
                "patient_id": patient_id,
                "patient_name": self.test_patient["name"],
                "date": tomorrow,
                "time": "10:00"
            },
            {
                "patient_id": patient_id,
                "patient_name": self.test_patient["name"],
                "date": tomorrow,
                "time": "16:30"
            },
            {
                "patient_id": patient_id,
                "patient_name": self.test_patient["name"],
                "date": day_after_tomorrow,
                "time": "14:15"
            }
        ]
        
        appointment_ids = []
        for i, appointment in enumerate(appointments):
            print(f"Creating appointment {i+1} for {appointment['date']} at {appointment['time']}...")
            response = requests.post(f"{BACKEND_URL}/appointments", json=appointment)
            self.assertEqual(response.status_code, 200, f"Failed to create appointment: {response.text}")
            
            appointment_data = response.json()
            appointment_id = appointment_data["id"]
            appointment_ids.append(appointment_id)
            self.created_resources["appointments"].append(appointment_id)
        
        # Get all notifications
        print("Getting all notifications to check scheduling...")
        response = requests.get(f"{BACKEND_URL}/notifications")
        self.assertEqual(response.status_code, 200, f"Failed to get notifications: {response.text}")
        
        notifications = response.json()
        
        # Filter notifications for our appointments
        appointment_notifications = [n for n in notifications if n["appointment_id"] in appointment_ids]
        
        # We should have 6 notifications (2 per appointment)
        self.assertEqual(len(appointment_notifications), 6, 
                         f"Expected 6 notifications for 3 appointments, got {len(appointment_notifications)}")
        
        # Group notifications by appointment
        notifications_by_appointment = {}
        for notification in appointment_notifications:
            appointment_id = notification["appointment_id"]
            if appointment_id not in notifications_by_appointment:
                notifications_by_appointment[appointment_id] = []
            notifications_by_appointment[appointment_id].append(notification)
        
        # Check scheduling for each appointment
        for i, appointment_id in enumerate(appointment_ids):
            appointment = appointments[i]
            appointment_notifications = notifications_by_appointment[appointment_id]
            
            # Should have 2 notifications per appointment
            self.assertEqual(len(appointment_notifications), 2, 
                            f"Expected 2 notifications for appointment {i+1}, got {len(appointment_notifications)}")
            
            # Get appointment datetime
            appointment_datetime = datetime.strptime(f"{appointment['date']} {appointment['time']}", "%Y-%m-%d %H:%M")
            
            for notification in appointment_notifications:
                scheduled_time = datetime.fromisoformat(notification["scheduled_time"].replace("Z", "+00:00"))
                
                if notification["notification_type"] == "1_day_before":
                    # 1 day before notification should be scheduled for 24 hours before appointment
                    expected_time = appointment_datetime - timedelta(days=1)
                    time_diff = abs((scheduled_time - expected_time).total_seconds())
                    
                    # Allow for a small difference due to processing time
                    self.assertLess(time_diff, 60, 
                                   f"1_day_before notification scheduled time differs by {time_diff} seconds from expected")
                    
                else:  # 1_hour_30_before
                    # 1h30 before notification should be scheduled for 1.5 hours before appointment
                    expected_time = appointment_datetime - timedelta(hours=1, minutes=30)
                    time_diff = abs((scheduled_time - expected_time).total_seconds())
                    
                    # Allow for a small difference due to processing time
                    self.assertLess(time_diff, 60, 
                                   f"1_hour_30_before notification scheduled time differs by {time_diff} seconds from expected")
        
        print(f"Notification scheduling tests successful")
        
        return patient_id, appointment_ids

if __name__ == "__main__":
    # Run the tests
    unittest.main(argv=['first-arg-is-ignored'], exit=False)