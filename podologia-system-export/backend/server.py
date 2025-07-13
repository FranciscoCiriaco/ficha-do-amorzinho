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
from datetime import datetime, timedelta

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

# Notification Models
class Notification(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    appointment_id: str
    patient_id: str
    patient_name: str
    patient_contact: str
    notification_type: str  # "1_day_before" or "1_hour_30_before"
    scheduled_time: datetime
    appointment_date: str
    appointment_time: str
    message: str
    sent: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

class NotificationCreate(BaseModel):
    appointment_id: str
    notification_type: str

# WhatsApp Message Templates
def generate_whatsapp_message(patient_name: str, appointment_date: str, appointment_time: str, notification_type: str) -> str:
    """Generate WhatsApp message based on notification type"""
    
    # Format date to Brazilian format
    try:
        date_obj = datetime.strptime(appointment_date, "%Y-%m-%d")
        formatted_date = date_obj.strftime("%d/%m/%Y")
    except:
        formatted_date = appointment_date
    
    if notification_type == "1_day_before":
        message = f"""🦶 *Lembrete de Consulta - Podologia*

Olá {patient_name}! 👋

Este é um lembrete de que você tem uma consulta agendada para *amanhã* ({formatted_date}) às *{appointment_time}*.

Por favor, confirme sua presença respondendo:
✅ *CONFIRMO* - se você comparecerá
❌ *CANCELAR* - se precisar cancelar

📍 Não se esqueça de trazer documentos e chegar com 10 minutos de antecedência.

Obrigado!"""
    
    else:  # 1_hour_30_before
        message = f"""🦶 *Lembrete de Consulta - Podologia*

Olá {patient_name}! 👋

Sua consulta está próxima! 

📅 Data: *{formatted_date}*
🕐 Horário: *{appointment_time}*

Você tem aproximadamente *1h30* para se preparar.

Por favor, confirme que está a caminho respondendo:
✅ *A CAMINHO* - se você está se dirigindo ao local
❌ *ATRASO* - se você vai se atrasar
❌ *CANCELAR* - se não puder comparecer

📍 Lembre-se de chegar com 10 minutos de antecedência.

Até logo!"""
    
    return message

def create_whatsapp_link(phone: str, message: str) -> str:
    """Create WhatsApp link with pre-filled message"""
    # Clean phone number (remove non-digits)
    clean_phone = ''.join(filter(str.isdigit, phone))
    
    # Add Brazil country code if not present
    if not clean_phone.startswith('55'):
        clean_phone = '55' + clean_phone
    
    # URL encode the message
    import urllib.parse
    encoded_message = urllib.parse.quote(message)
    
    return f"https://wa.me/{clean_phone}?text={encoded_message}"
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

async def create_automatic_notifications(appointment_data: dict, patient_data: dict):
    """Create automatic notifications for an appointment"""
    try:
        appointment_datetime = datetime.strptime(f"{appointment_data['date']} {appointment_data['time']}", "%Y-%m-%d %H:%M")
        
        # Create 1 day before notification
        one_day_before = appointment_datetime - timedelta(days=1)
        one_day_message = generate_whatsapp_message(
            patient_data['name'], 
            appointment_data['date'], 
            appointment_data['time'], 
            "1_day_before"
        )
        
        notification_1_day = Notification(
            appointment_id=appointment_data['id'],
            patient_id=appointment_data['patient_id'],
            patient_name=patient_data['name'],
            patient_contact=patient_data['contact'],
            notification_type="1_day_before",
            scheduled_time=one_day_before,
            appointment_date=appointment_data['date'],
            appointment_time=appointment_data['time'],
            message=one_day_message
        )
        
        # Create 1 hour 30 minutes before notification
        one_hour_30_before = appointment_datetime - timedelta(hours=1, minutes=30)
        one_hour_30_message = generate_whatsapp_message(
            patient_data['name'], 
            appointment_data['date'], 
            appointment_data['time'], 
            "1_hour_30_before"
        )
        
        notification_1h30 = Notification(
            appointment_id=appointment_data['id'],
            patient_id=appointment_data['patient_id'],
            patient_name=patient_data['name'],
            patient_contact=patient_data['contact'],
            notification_type="1_hour_30_before",
            scheduled_time=one_hour_30_before,
            appointment_date=appointment_data['date'],
            appointment_time=appointment_data['time'],
            message=one_hour_30_message
        )
        
        # Save notifications to database
        await db.notifications.insert_one(notification_1_day.dict())
        await db.notifications.insert_one(notification_1h30.dict())
        
        return True
    except Exception as e:
        print(f"Error creating notifications: {e}")
        return False

# Appointment endpoints
@api_router.post("/appointments", response_model=Appointment)
async def create_appointment(appointment: AppointmentCreate):
    try:
        appointment_dict = appointment.dict()
        appointment_obj = Appointment(**appointment_dict)
        await db.appointments.insert_one(appointment_obj.dict())
        
        # Get patient data for notifications
        patient = await db.patients.find_one({"id": appointment.patient_id})
        if patient:
            # Create automatic notifications
            await create_automatic_notifications(appointment_obj.dict(), patient)
        
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

# Notification endpoints
@api_router.get("/notifications", response_model=List[Notification])
async def get_notifications():
    try:
        notifications = await db.notifications.find().to_list(1000)
        return [Notification(**notification) for notification in notifications]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/notifications/pending")
async def get_pending_notifications():
    try:
        current_time = datetime.utcnow()
        
        # Get notifications that are due (scheduled time is past) and not sent yet
        pending_notifications = await db.notifications.find({
            "scheduled_time": {"$lte": current_time},
            "sent": False
        }).to_list(100)
        
        result = []
        for notification in pending_notifications:
            notification_obj = Notification(**notification)
            whatsapp_link = create_whatsapp_link(notification_obj.patient_contact, notification_obj.message)
            
            result.append({
                "id": notification_obj.id,
                "patient_name": notification_obj.patient_name,
                "patient_contact": notification_obj.patient_contact,
                "notification_type": notification_obj.notification_type,
                "appointment_date": notification_obj.appointment_date,
                "appointment_time": notification_obj.appointment_time,
                "message": notification_obj.message,
                "whatsapp_link": whatsapp_link,
                "scheduled_time": notification_obj.scheduled_time
            })
        
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.post("/notifications/{notification_id}/mark-sent")
async def mark_notification_sent(notification_id: str):
    try:
        result = await db.notifications.update_one(
            {"id": notification_id},
            {"$set": {"sent": True}}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Notification not found")
        
        return {"message": "Notification marked as sent"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@api_router.get("/notifications/upcoming")
async def get_upcoming_notifications():
    try:
        current_time = datetime.utcnow()
        next_24_hours = current_time + timedelta(hours=24)
        
        # Get notifications scheduled for the next 24 hours
        upcoming_notifications = await db.notifications.find({
            "scheduled_time": {
                "$gte": current_time,
                "$lte": next_24_hours
            },
            "sent": False
        }).to_list(100)
        
        result = []
        for notification in upcoming_notifications:
            notification_obj = Notification(**notification)
            whatsapp_link = create_whatsapp_link(notification_obj.patient_contact, notification_obj.message)
            
            result.append({
                "id": notification_obj.id,
                "patient_name": notification_obj.patient_name,
                "patient_contact": notification_obj.patient_contact,
                "notification_type": notification_obj.notification_type,
                "appointment_date": notification_obj.appointment_date,
                "appointment_time": notification_obj.appointment_time,
                "message": notification_obj.message,
                "whatsapp_link": whatsapp_link,
                "scheduled_time": notification_obj.scheduled_time,
                "time_until_send": notification_obj.scheduled_time - current_time
            })
        
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
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