from fastapi import FastAPI, APIRouter, HTTPException
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Patient Models
class Patient(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    address: str
    neighborhood: str
    city: str
    state: str
    cep: str
    birth_date: str
    sex: str
    profession: str
    contact: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class PatientCreate(BaseModel):
    name: str
    address: str
    neighborhood: str
    city: str
    state: str
    cep: str
    birth_date: str
    sex: str
    profession: str
    contact: str

# Anamnesis Models
class GeneralData(BaseModel):
    chief_complaint: str
    podiatrist_frequency: str
    medications: bool
    medication_details: str
    allergies: bool
    allergy_details: str
    work_position: str
    insoles: bool
    smoking: bool
    pregnant: bool
    breastfeeding: bool
    physical_activity: bool
    physical_activity_frequency: str
    footwear_type: str
    daily_footwear_type: str

class ClinicalData(BaseModel):
    # Medical conditions
    gestante: bool = False
    osteoporose: bool = False
    cardiopatia: bool = False
    marca_passo: bool = False
    hipertireoidismo: bool = False
    hipotireoidismo: bool = False
    hipertensao: bool = False
    hipotensao: bool = False
    renal: bool = False
    neuropatia: bool = False
    reumatismo: bool = False
    quimioterapia_radioterapia: bool = False
    antecedentes_oncologicos: bool = False
    cirurgia_mmii: bool = False
    alteracoes_comprometimento_vasculares: bool = False
    
    # Diabetes related
    diabetes: bool = False
    diabetes_type: str = ""
    glucose_level: str = ""
    last_verification_date: str = ""
    
    # Insulin related
    insulin: bool = False
    insulin_type: str = ""  # injectable or oral
    
    # Diet related
    diet: bool = False
    diet_type: str = ""  # dietary

class ResponsibilityTerm(BaseModel):
    patient_name: str
    rg: str
    cpf: str
    signature: str  # base64 encoded signature image
    date: str

class Anamnesis(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    patient_id: str
    general_data: GeneralData
    clinical_data: ClinicalData
    responsibility_term: ResponsibilityTerm
    observations: str = ""  # Campo para observações dos procedimentos
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class AnamnesisCreate(BaseModel):
    patient_id: str
    general_data: GeneralData
    clinical_data: ClinicalData
    responsibility_term: ResponsibilityTerm
    observations: str = ""

# Appointment Models
class Appointment(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    patient_id: str
    patient_name: str
    date: str
    time: str
    status: str = "scheduled"  # scheduled, confirmed, completed, cancelled
    created_at: datetime = Field(default_factory=datetime.utcnow)

class AppointmentCreate(BaseModel):
    patient_id: str
    patient_name: str
    date: str
    time: str

# Patient endpoints
@api_router.post("/patients", response_model=Patient)
async def create_patient(patient: PatientCreate):
    try:
        patient_dict = patient.dict()
        patient_obj = Patient(**patient_dict)
        await db.patients.insert_one(patient_obj.dict())
        return patient_obj
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/patients", response_model=List[Patient])
async def get_patients():
    try:
        patients = await db.patients.find().to_list(1000)
        return [Patient(**patient) for patient in patients]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/patients/{patient_id}", response_model=Patient)
async def get_patient(patient_id: str):
    try:
        patient = await db.patients.find_one({"id": patient_id})
        if not patient:
            raise HTTPException(status_code=404, detail="Patient not found")
        return Patient(**patient)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.put("/patients/{patient_id}", response_model=Patient)
async def update_patient(patient_id: str, patient_update: PatientCreate):
    try:
        patient_dict = patient_update.dict()
        patient_dict["updated_at"] = datetime.utcnow()
        
        result = await db.patients.update_one(
            {"id": patient_id},
            {"$set": patient_dict}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        updated_patient = await db.patients.find_one({"id": patient_id})
        return Patient(**updated_patient)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.delete("/patients/{patient_id}")
async def delete_patient(patient_id: str):
    try:
        result = await db.patients.delete_one({"id": patient_id})
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Patient not found")
        return {"message": "Patient deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Anamnesis endpoints
@api_router.post("/anamnesis", response_model=Anamnesis)
async def create_anamnesis(anamnesis: AnamnesisCreate):
    try:
        anamnesis_dict = anamnesis.dict()
        anamnesis_obj = Anamnesis(**anamnesis_dict)
        await db.anamnesis.insert_one(anamnesis_obj.dict())
        return anamnesis_obj
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/anamnesis/{patient_id}", response_model=List[Anamnesis])
async def get_patient_anamnesis(patient_id: str):
    try:
        anamnesis_list = await db.anamnesis.find({"patient_id": patient_id}).to_list(1000)
        return [Anamnesis(**anamnesis) for anamnesis in anamnesis_list]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/anamnesis/form/{anamnesis_id}", response_model=Anamnesis)
async def get_anamnesis(anamnesis_id: str):
    try:
        anamnesis = await db.anamnesis.find_one({"id": anamnesis_id})
        if not anamnesis:
            raise HTTPException(status_code=404, detail="Anamnesis not found")
        return Anamnesis(**anamnesis)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.put("/anamnesis/{anamnesis_id}", response_model=Anamnesis)
async def update_anamnesis(anamnesis_id: str, anamnesis_update: AnamnesisCreate):
    try:
        anamnesis_dict = anamnesis_update.dict()
        anamnesis_dict["updated_at"] = datetime.utcnow()
        
        result = await db.anamnesis.update_one(
            {"id": anamnesis_id},
            {"$set": anamnesis_dict}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Anamnesis not found")
        
        updated_anamnesis = await db.anamnesis.find_one({"id": anamnesis_id})
        return Anamnesis(**updated_anamnesis)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Appointment endpoints
@api_router.post("/appointments", response_model=Appointment)
async def create_appointment(appointment: AppointmentCreate):
    try:
        appointment_dict = appointment.dict()
        appointment_obj = Appointment(**appointment_dict)
        await db.appointments.insert_one(appointment_obj.dict())
        return appointment_obj
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/appointments", response_model=List[Appointment])
async def get_appointments():
    try:
        appointments = await db.appointments.find().to_list(1000)
        return [Appointment(**appointment) for appointment in appointments]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/appointments/{patient_id}", response_model=List[Appointment])
async def get_patient_appointments(patient_id: str):
    try:
        appointments = await db.appointments.find({"patient_id": patient_id}).to_list(1000)
        return [Appointment(**appointment) for appointment in appointments]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Search endpoint
@api_router.get("/search/patients")
async def search_patients(q: str):
    try:
        # Search by name, CPF, or contact
        patients = await db.patients.find({
            "$or": [
                {"name": {"$regex": q, "$options": "i"}},
                {"contact": {"$regex": q, "$options": "i"}},
                {"cpf": {"$regex": q, "$options": "i"}}
            ]
        }).to_list(100)
        
        return [Patient(**patient) for patient in patients]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()