import requests
import json
import time
import unittest
from datetime import datetime

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

if __name__ == "__main__":
    # Run the tests
    unittest.main(argv=['first-arg-is-ignored'], exit=False)