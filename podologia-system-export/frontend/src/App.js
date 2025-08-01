import React, { useState, useEffect, useRef } from "react";
import "./App.css";
import { BrowserRouter, Routes, Route, Link, useNavigate, useParams } from "react-router-dom";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

// Signature Canvas Component
const SignatureCanvas = ({ onSignatureChange }) => {
  const canvasRef = useRef(null);
  const [isDrawing, setIsDrawing] = useState(false);

  const startDrawing = (e) => {
    setIsDrawing(true);
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const ctx = canvas.getContext('2d');
    ctx.beginPath();
    ctx.moveTo(x, y);
  };

  const draw = (e) => {
    if (!isDrawing) return;
    
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const ctx = canvas.getContext('2d');
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#000';
    ctx.lineTo(x, y);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(x, y);
  };

  const stopDrawing = () => {
    setIsDrawing(false);
    const canvas = canvasRef.current;
    const signature = canvas.toDataURL();
    onSignatureChange(signature);
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    onSignatureChange("");
  };

  return (
    <div className="signature-container">
      <canvas
        ref={canvasRef}
        width={400}
        height={200}
        className="signature-canvas"
        onMouseDown={startDrawing}
        onMouseMove={draw}
        onMouseUp={stopDrawing}
        onMouseLeave={stopDrawing}
      />
      <button type="button" onClick={clearCanvas} className="clear-signature-btn">
        Limpar Assinatura
      </button>
    </div>
  );
};

// Patient Registration Component
const PatientRegistration = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: "",
    address: "",
    neighborhood: "",
    city: "",
    state: "",
    cep: "",
    birth_date: "",
    sex: "",
    profession: "",
    contact: ""
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(`${API}/patients`, formData);
      alert("Paciente cadastrado com sucesso!");
      navigate(`/anamnesis/${response.data.id}`);
    } catch (error) {
      console.error("Erro ao cadastrar paciente:", error);
      alert("Erro ao cadastrar paciente");
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="container">
      <div className="form-header">
        <h2>📋 Cadastro de Paciente</h2>
      </div>
      <form onSubmit={handleSubmit} className="patient-form">
        <div className="form-group">
          <label>Nome *</label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            required
          />
        </div>
        
        <div className="form-group">
          <label>Endereço *</label>
          <input
            type="text"
            name="address"
            value={formData.address}
            onChange={handleChange}
            required
          />
        </div>
        
        <div className="form-row">
          <div className="form-group">
            <label>Bairro *</label>
            <input
              type="text"
              name="neighborhood"
              value={formData.neighborhood}
              onChange={handleChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Cidade *</label>
            <input
              type="text"
              name="city"
              value={formData.city}
              onChange={handleChange}
              required
            />
          </div>
        </div>
        
        <div className="form-row">
          <div className="form-group">
            <label>Estado *</label>
            <input
              type="text"
              name="state"
              value={formData.state}
              onChange={handleChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>CEP *</label>
            <input
              type="text"
              name="cep"
              value={formData.cep}
              onChange={handleChange}
              required
            />
          </div>
        </div>
        
        <div className="form-row">
          <div className="form-group">
            <label>Data de Nascimento *</label>
            <input
              type="date"
              name="birth_date"
              value={formData.birth_date}
              onChange={handleChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Sexo *</label>
            <select
              name="sex"
              value={formData.sex}
              onChange={handleChange}
              required
            >
              <option value="">Selecione</option>
              <option value="Feminino">Feminino</option>
              <option value="Masculino">Masculino</option>
            </select>
          </div>
        </div>
        
        <div className="form-row">
          <div className="form-group">
            <label>Profissão *</label>
            <input
              type="text"
              name="profession"
              value={formData.profession}
              onChange={handleChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Número de Contato (WhatsApp) *</label>
            <input
              type="text"
              name="contact"
              value={formData.contact}
              onChange={handleChange}
              required
            />
          </div>
        </div>
        
        <button type="submit" className="submit-btn">
          Cadastrar Paciente
        </button>
      </form>
    </div>
  );
};

// Anamnesis Form Component
const AnamnesisForm = () => {
  const { patientId } = useParams();
  const navigate = useNavigate();
  const [patient, setPatient] = useState(null);
  const [signature, setSignature] = useState("");
  const [formData, setFormData] = useState({
    general_data: {
      chief_complaint: "",
      podiatrist_frequency: "",
      medications: false,
      medication_details: "",
      allergies: false,
      allergy_details: "",
      work_position: "",
      insoles: false,
      smoking: false,
      pregnant: false,
      breastfeeding: false,
      physical_activity: false,
      physical_activity_frequency: "",
      footwear_type: "",
      daily_footwear_type: ""
    },
    clinical_data: {
      gestante: false,
      osteoporose: false,
      cardiopatia: false,
      marca_passo: false,
      hipertireoidismo: false,
      hipotireoidismo: false,
      hipertensao: false,
      hipotensao: false,
      renal: false,
      neuropatia: false,
      reumatismo: false,
      quimioterapia_radioterapia: false,
      antecedentes_oncologicos: false,
      cirurgia_mmii: false,
      alteracoes_comprometimento_vasculares: false,
      diabetes: false,
      diabetes_type: "",
      glucose_level: "",
      last_verification_date: "",
      insulin: false,
      insulin_type: "",
      diet: false,
      diet_type: ""
    },
    responsibility_term: {
      patient_name: "",
      rg: "",
      cpf: "",
      signature: "",
      date: new Date().toISOString().split('T')[0]
    },
    observations: ""
  });

  useEffect(() => {
    const fetchPatient = async () => {
      try {
        const response = await axios.get(`${API}/patients/${patientId}`);
        setPatient(response.data);
        setFormData(prev => ({
          ...prev,
          responsibility_term: {
            ...prev.responsibility_term,
            patient_name: response.data.name
          }
        }));
      } catch (error) {
        console.error("Erro ao carregar paciente:", error);
      }
    };

    if (patientId) {
      fetchPatient();
    }
  }, [patientId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const submitData = {
        ...formData,
        patient_id: patientId,
        responsibility_term: {
          ...formData.responsibility_term,
          signature: signature
        }
      };
      
      await axios.post(`${API}/anamnesis`, submitData);
      alert("Ficha de anamnese salva com sucesso!");
      navigate("/patients");
    } catch (error) {
      console.error("Erro ao salvar anamnese:", error);
      alert("Erro ao salvar ficha de anamnese");
    }
  };

  const handleGeneralDataChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      general_data: {
        ...prev.general_data,
        [name]: type === 'checkbox' ? checked : value
      }
    }));
  };

  const handleClinicalDataChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      clinical_data: {
        ...prev.clinical_data,
        [name]: type === 'checkbox' ? checked : value
      }
    }));
  };

  const handleResponsibilityTermChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      responsibility_term: {
        ...prev.responsibility_term,
        [name]: value
      }
    }));
  };

  const handleObservationsChange = (e) => {
    setFormData(prev => ({
      ...prev,
      observations: e.target.value
    }));
  };

  if (!patient) {
    return <div>Carregando...</div>;
  }

  return (
    <div className="container">
      <div className="form-header">
        <h2>🩺 Ficha de Anamnese</h2>
        <p>Paciente: {patient.name}</p>
      </div>
      
      <form onSubmit={handleSubmit} className="anamnesis-form">
        {/* General Data Section */}
        <div className="form-section">
          <h3>Dados Gerais</h3>
          
          <div className="form-group">
            <label>Queixa Principal *</label>
            <textarea
              name="chief_complaint"
              value={formData.general_data.chief_complaint}
              onChange={handleGeneralDataChange}
              required
              rows="3"
            />
          </div>
          
          <div className="form-group">
            <label>Frequência com Podólogo</label>
            <input
              type="text"
              name="podiatrist_frequency"
              value={formData.general_data.podiatrist_frequency}
              onChange={handleGeneralDataChange}
            />
          </div>
          
          <div className="checkbox-group">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="medications"
                checked={formData.general_data.medications}
                onChange={handleGeneralDataChange}
              />
              <label>Faz uso de algum medicamento?</label>
            </div>
            {formData.general_data.medications && (
              <div className="form-group">
                <label>Qual?</label>
                <input
                  type="text"
                  name="medication_details"
                  value={formData.general_data.medication_details}
                  onChange={handleGeneralDataChange}
                />
              </div>
            )}
          </div>
          
          <div className="checkbox-group">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="allergies"
                checked={formData.general_data.allergies}
                onChange={handleGeneralDataChange}
              />
              <label>Alérgico?</label>
            </div>
            {formData.general_data.allergies && (
              <div className="form-group">
                <label>Quais substâncias?</label>
                <input
                  type="text"
                  name="allergy_details"
                  value={formData.general_data.allergy_details}
                  onChange={handleGeneralDataChange}
                />
              </div>
            )}
          </div>
          
          <div className="form-group">
            <label>Posição de Trabalho</label>
            <select
              name="work_position"
              value={formData.general_data.work_position}
              onChange={handleGeneralDataChange}
            >
              <option value="">Selecione</option>
              <option value="Em pé">Em pé</option>
              <option value="Sentado">Sentado</option>
              <option value="Andando">Andando</option>
              <option value="Ortopédica/Descanso">Ortopédica/Descanso</option>
            </select>
          </div>
          
          <div className="checkbox-row">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="insoles"
                checked={formData.general_data.insoles}
                onChange={handleGeneralDataChange}
              />
              <label>Faz uso de palmilha?</label>
            </div>
            
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="smoking"
                checked={formData.general_data.smoking}
                onChange={handleGeneralDataChange}
              />
              <label>É fumante?</label>
            </div>
            
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="pregnant"
                checked={formData.general_data.pregnant}
                onChange={handleGeneralDataChange}
              />
              <label>Está gestante?</label>
            </div>
            
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="breastfeeding"
                checked={formData.general_data.breastfeeding}
                onChange={handleGeneralDataChange}
              />
              <label>Está amamentando?</label>
            </div>
          </div>
          
          <div className="checkbox-group">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="physical_activity"
                checked={formData.general_data.physical_activity}
                onChange={handleGeneralDataChange}
              />
              <label>Pratica atividade física?</label>
            </div>
            {formData.general_data.physical_activity && (
              <div className="form-group">
                <label>Frequência:</label>
                <input
                  type="text"
                  name="physical_activity_frequency"
                  value={formData.general_data.physical_activity_frequency}
                  onChange={handleGeneralDataChange}
                />
              </div>
            )}
          </div>
          
          <div className="form-group">
            <label>Qual esporte e tipo de calçado?</label>
            <input
              type="text"
              name="footwear_type"
              value={formData.general_data.footwear_type}
              onChange={handleGeneralDataChange}
            />
          </div>
          
          <div className="form-group">
            <label>Tipo de calçado de uso diário:</label>
            <input
              type="text"
              name="daily_footwear_type"
              value={formData.general_data.daily_footwear_type}
              onChange={handleGeneralDataChange}
            />
          </div>
        </div>

        {/* Clinical Data Section */}
        <div className="form-section">
          <h3>Dados Clínicos</h3>
          
          <div className="clinical-checkboxes">
            <div className="checkbox-grid">
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="gestante"
                  checked={formData.clinical_data.gestante}
                  onChange={handleClinicalDataChange}
                />
                <label>Gestante</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="osteoporose"
                  checked={formData.clinical_data.osteoporose}
                  onChange={handleClinicalDataChange}
                />
                <label>Osteoporose</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="cardiopatia"
                  checked={formData.clinical_data.cardiopatia}
                  onChange={handleClinicalDataChange}
                />
                <label>Cardiopatia</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="marca_passo"
                  checked={formData.clinical_data.marca_passo}
                  onChange={handleClinicalDataChange}
                />
                <label>Marca Passo</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="hipertireoidismo"
                  checked={formData.clinical_data.hipertireoidismo}
                  onChange={handleClinicalDataChange}
                />
                <label>Hipertireoidismo</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="hipotireoidismo"
                  checked={formData.clinical_data.hipotireoidismo}
                  onChange={handleClinicalDataChange}
                />
                <label>Hipotireoidismo</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="hipertensao"
                  checked={formData.clinical_data.hipertensao}
                  onChange={handleClinicalDataChange}
                />
                <label>Hipertensão</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="hipotensao"
                  checked={formData.clinical_data.hipotensao}
                  onChange={handleClinicalDataChange}
                />
                <label>Hipotensão</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="renal"
                  checked={formData.clinical_data.renal}
                  onChange={handleClinicalDataChange}
                />
                <label>Renal</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="neuropatia"
                  checked={formData.clinical_data.neuropatia}
                  onChange={handleClinicalDataChange}
                />
                <label>Neuropatia</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="reumatismo"
                  checked={formData.clinical_data.reumatismo}
                  onChange={handleClinicalDataChange}
                />
                <label>Reumatismo</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="quimioterapia_radioterapia"
                  checked={formData.clinical_data.quimioterapia_radioterapia}
                  onChange={handleClinicalDataChange}
                />
                <label>Quimioterapia/Radioterapia</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="antecedentes_oncologicos"
                  checked={formData.clinical_data.antecedentes_oncologicos}
                  onChange={handleClinicalDataChange}
                />
                <label>Antecedentes Oncológicos</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="cirurgia_mmii"
                  checked={formData.clinical_data.cirurgia_mmii}
                  onChange={handleClinicalDataChange}
                />
                <label>Cirurgia MMII</label>
              </div>
              
              <div className="checkbox-item">
                <input
                  type="checkbox"
                  name="alteracoes_comprometimento_vasculares"
                  checked={formData.clinical_data.alteracoes_comprometimento_vasculares}
                  onChange={handleClinicalDataChange}
                />
                <label>Alterações ou Comprometimento Vasculares</label>
              </div>
            </div>
          </div>
          
          {/* Diabetes Section */}
          <div className="diabetes-section">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="diabetes"
                checked={formData.clinical_data.diabetes}
                onChange={handleClinicalDataChange}
              />
              <label>Diabetes</label>
            </div>
            
            {formData.clinical_data.diabetes && (
              <div className="diabetes-details">
                <div className="form-group">
                  <label>Tipo:</label>
                  <input
                    type="text"
                    name="diabetes_type"
                    value={formData.clinical_data.diabetes_type}
                    onChange={handleClinicalDataChange}
                  />
                </div>
                
                <div className="form-group">
                  <label>Taxa glicêmica:</label>
                  <input
                    type="text"
                    name="glucose_level"
                    value={formData.clinical_data.glucose_level}
                    onChange={handleClinicalDataChange}
                  />
                </div>
                
                <div className="form-group">
                  <label>Data da última verificação:</label>
                  <input
                    type="date"
                    name="last_verification_date"
                    value={formData.clinical_data.last_verification_date}
                    onChange={handleClinicalDataChange}
                  />
                </div>
              </div>
            )}
          </div>
          
          {/* Insulin Section */}
          <div className="insulin-section">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="insulin"
                checked={formData.clinical_data.insulin}
                onChange={handleClinicalDataChange}
              />
              <label>Insulina</label>
            </div>
            
            {formData.clinical_data.insulin && (
              <div className="insulin-details">
                <div className="form-group">
                  <label>Tipo:</label>
                  <select
                    name="insulin_type"
                    value={formData.clinical_data.insulin_type}
                    onChange={handleClinicalDataChange}
                  >
                    <option value="">Selecione</option>
                    <option value="Injetável">Injetável</option>
                    <option value="Oral">Oral</option>
                  </select>
                </div>
              </div>
            )}
          </div>
          
          {/* Diet Section */}
          <div className="diet-section">
            <div className="checkbox-item">
              <input
                type="checkbox"
                name="diet"
                checked={formData.clinical_data.diet}
                onChange={handleClinicalDataChange}
              />
              <label>Dieta Hídrica</label>
            </div>
            
            {formData.clinical_data.diet && (
              <div className="diet-details">
                <div className="form-group">
                  <label>Tipo:</label>
                  <input
                    type="text"
                    name="diet_type"
                    value={formData.clinical_data.diet_type}
                    onChange={handleClinicalDataChange}
                  />
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Responsibility Term Section */}
        <div className="form-section">
          <h3>Termo de Responsabilidade</h3>
          
          <div className="form-group">
            <label>Nome do Paciente</label>
            <input
              type="text"
              name="patient_name"
              value={formData.responsibility_term.patient_name}
              onChange={handleResponsibilityTermChange}
              required
            />
          </div>
          
          <div className="form-row">
            <div className="form-group">
              <label>RG *</label>
              <input
                type="text"
                name="rg"
                value={formData.responsibility_term.rg}
                onChange={handleResponsibilityTermChange}
                required
              />
            </div>
            
            <div className="form-group">
              <label>CPF *</label>
              <input
                type="text"
                name="cpf"
                value={formData.responsibility_term.cpf}
                onChange={handleResponsibilityTermChange}
                required
              />
            </div>
          </div>
          
          <div className="form-group">
            <label>Data</label>
            <input
              type="date"
              name="date"
              value={formData.responsibility_term.date}
              onChange={handleResponsibilityTermChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Assinatura do Paciente *</label>
            <SignatureCanvas onSignatureChange={setSignature} />
          </div>
          
          <div className="responsibility-text">
            <p>
              Eu, <strong>{formData.responsibility_term.patient_name}</strong>, 
              portador(a) do RG nº <strong>{formData.responsibility_term.rg}</strong> e 
              inscrito(a) no CPF nº <strong>{formData.responsibility_term.cpf}</strong>, 
              por minha livre iniciativa, aceito submeter-me ao procedimento de podologia.
            </p>
          </div>
        </div>

        {/* Observations Section */}
        <div className="form-section">
          <h3>📝 Observações dos Procedimentos</h3>
          
          <div className="form-group">
            <label>Observações e Procedimentos Realizados</label>
            <textarea
              name="observations"
              value={formData.observations}
              onChange={handleObservationsChange}
              rows="6"
              placeholder="Descreva os procedimentos realizados, observações do tratamento, recomendações, etc..."
            />
          </div>
        </div>
        
        <button type="submit" className="submit-btn">
          Salvar Ficha de Anamnese
        </button>
      </form>
    </div>
  );
};

// Patients List Component
const PatientsList = () => {
  const [patients, setPatients] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [filteredPatients, setFilteredPatients] = useState([]);

  useEffect(() => {
    const fetchPatients = async () => {
      try {
        const response = await axios.get(`${API}/patients`);
        setPatients(response.data);
        setFilteredPatients(response.data);
      } catch (error) {
        console.error("Erro ao carregar pacientes:", error);
      }
    };

    fetchPatients();
  }, []);

  useEffect(() => {
    const filtered = patients.filter(patient => 
      patient.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      patient.contact.includes(searchTerm)
    );
    setFilteredPatients(filtered);
  }, [searchTerm, patients]);

  return (
    <div className="container">
      <div className="form-header">
        <h2>👥 Lista de Pacientes</h2>
        <Link to="/register" className="add-btn">
          + Novo Paciente
        </Link>
      </div>
      
      <div className="search-bar">
        <input
          type="text"
          placeholder="Buscar por nome ou telefone..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>
      
      <div className="patients-grid">
        {filteredPatients.map(patient => (
          <div key={patient.id} className="patient-card">
            <h3>{patient.name}</h3>
            <p><strong>Telefone:</strong> {patient.contact}</p>
            <p><strong>Data Nascimento:</strong> {patient.birth_date}</p>
            <p><strong>Cidade:</strong> {patient.city}</p>
            <div className="card-actions">
              <Link to={`/anamnesis/${patient.id}`} className="btn btn-primary">
                Nova Anamnese
              </Link>
              <Link to={`/patient/${patient.id}`} className="btn btn-secondary">
                Ver Histórico
              </Link>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// Notifications Component
const Notifications = () => {
  const [pendingNotifications, setPendingNotifications] = useState([]);
  const [upcomingNotifications, setUpcomingNotifications] = useState([]);
  const [activeTab, setActiveTab] = useState("pending");

  useEffect(() => {
    fetchNotifications();
    // Refresh every 5 minutes
    const interval = setInterval(fetchNotifications, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  const fetchNotifications = async () => {
    try {
      const [pendingResponse, upcomingResponse] = await Promise.all([
        axios.get(`${API}/notifications/pending`),
        axios.get(`${API}/notifications/upcoming`)
      ]);
      
      setPendingNotifications(pendingResponse.data);
      setUpcomingNotifications(upcomingResponse.data);
    } catch (error) {
      console.error("Erro ao carregar notificações:", error);
    }
  };

  const markAsSent = async (notificationId) => {
    try {
      await axios.post(`${API}/notifications/${notificationId}/mark-sent`);
      fetchNotifications(); // Refresh the list
      alert("Notificação marcada como enviada!");
    } catch (error) {
      console.error("Erro ao marcar notificação como enviada:", error);
      alert("Erro ao marcar notificação como enviada");
    }
  };

  const openWhatsApp = (whatsappLink, notificationId) => {
    window.open(whatsappLink, '_blank');
    // Optionally mark as sent immediately
    setTimeout(() => {
      if (window.confirm("Deseja marcar esta notificação como enviada?")) {
        markAsSent(notificationId);
      }
    }, 2000);
  };

  const formatDateTime = (dateTimeString) => {
    const date = new Date(dateTimeString);
    return date.toLocaleString('pt-BR');
  };

  const getNotificationTypeLabel = (type) => {
    return type === "1_day_before" ? "1 dia antes" : "1h30 antes";
  };

  const getTimeDifference = (scheduledTime) => {
    const now = new Date();
    const scheduled = new Date(scheduledTime);
    const diffMs = scheduled - now;
    
    if (diffMs < 0) {
      return "Atrasado";
    }
    
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
    
    if (diffHours > 0) {
      return `${diffHours}h ${diffMinutes}m`;
    } else {
      return `${diffMinutes}m`;
    }
  };

  return (
    <div className="container">
      <div className="form-header">
        <h2>🔔 Notificações WhatsApp</h2>
        <button onClick={fetchNotifications} className="add-btn">
          🔄 Atualizar
        </button>
      </div>

      <div className="notification-tabs">
        <button 
          className={`tab-btn ${activeTab === 'pending' ? 'active' : ''}`}
          onClick={() => setActiveTab('pending')}
        >
          📢 Pendentes ({pendingNotifications.length})
        </button>
        <button 
          className={`tab-btn ${activeTab === 'upcoming' ? 'active' : ''}`}
          onClick={() => setActiveTab('upcoming')}
        >
          ⏰ Próximas ({upcomingNotifications.length})
        </button>
      </div>

      {activeTab === 'pending' && (
        <div className="notifications-section">
          <h3>📢 Notificações Pendentes</h3>
          {pendingNotifications.length === 0 ? (
            <p className="no-notifications">Nenhuma notificação pendente no momento.</p>
          ) : (
            <div className="notifications-grid">
              {pendingNotifications.map(notification => (
                <div key={notification.id} className="notification-card pending">
                  <div className="notification-header">
                    <h4>{notification.patient_name}</h4>
                    <span className="notification-type">
                      {getNotificationTypeLabel(notification.notification_type)}
                    </span>
                  </div>
                  
                  <div className="notification-details">
                    <p><strong>📅 Data:</strong> {new Date(notification.appointment_date).toLocaleDateString('pt-BR')}</p>
                    <p><strong>🕐 Horário:</strong> {notification.appointment_time}</p>
                    <p><strong>📱 Contato:</strong> {notification.patient_contact}</p>
                  </div>
                  
                  <div className="notification-message">
                    <h5>💬 Mensagem:</h5>
                    <div className="message-preview">
                      {notification.message.substring(0, 100)}...
                    </div>
                  </div>
                  
                  <div className="notification-actions">
                    <button 
                      onClick={() => openWhatsApp(notification.whatsapp_link, notification.id)}
                      className="whatsapp-btn"
                    >
                      📱 Enviar WhatsApp
                    </button>
                    <button 
                      onClick={() => markAsSent(notification.id)}
                      className="mark-sent-btn"
                    >
                      ✅ Marcar como Enviada
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === 'upcoming' && (
        <div className="notifications-section">
          <h3>⏰ Próximas Notificações</h3>
          {upcomingNotifications.length === 0 ? (
            <p className="no-notifications">Nenhuma notificação programada para as próximas 24 horas.</p>
          ) : (
            <div className="notifications-grid">
              {upcomingNotifications.map(notification => (
                <div key={notification.id} className="notification-card upcoming">
                  <div className="notification-header">
                    <h4>{notification.patient_name}</h4>
                    <span className="notification-type">
                      {getNotificationTypeLabel(notification.notification_type)}
                    </span>
                  </div>
                  
                  <div className="notification-details">
                    <p><strong>📅 Data:</strong> {new Date(notification.appointment_date).toLocaleDateString('pt-BR')}</p>
                    <p><strong>🕐 Horário:</strong> {notification.appointment_time}</p>
                    <p><strong>📱 Contato:</strong> {notification.patient_contact}</p>
                    <p><strong>⏱️ Enviar em:</strong> {getTimeDifference(notification.scheduled_time)}</p>
                  </div>
                  
                  <div className="notification-message">
                    <h5>💬 Mensagem programada:</h5>
                    <div className="message-preview">
                      {notification.message.substring(0, 100)}...
                    </div>
                  </div>
                  
                  <div className="notification-actions">
                    <button 
                      onClick={() => {
                        const modal = document.createElement('div');
                        modal.className = 'message-modal';
                        modal.innerHTML = `
                          <div class="modal-content">
                            <h3>Mensagem completa</h3>
                            <pre>${notification.message}</pre>
                            <button onclick="this.parentElement.parentElement.remove()">Fechar</button>
                          </div>
                        `;
                        document.body.appendChild(modal);
                      }}
                      className="preview-btn"
                    >
                      👁️ Ver Mensagem
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};
const Appointments = () => {
  const [appointments, setAppointments] = useState([]);
  const [patients, setPatients] = useState([]);
  const [selectedPatient, setSelectedPatient] = useState("");
  const [selectedDate, setSelectedDate] = useState("");
  const [selectedTime, setSelectedTime] = useState("");
  const [currentDate, setCurrentDate] = useState(new Date());
  const [showForm, setShowForm] = useState(false);

  useEffect(() => {
    fetchAppointments();
    fetchPatients();
  }, []);

  const fetchAppointments = async () => {
    try {
      const response = await axios.get(`${API}/appointments`);
      setAppointments(response.data);
    } catch (error) {
      console.error("Erro ao carregar agendamentos:", error);
    }
  };

  const fetchPatients = async () => {
    try {
      const response = await axios.get(`${API}/patients`);
      setPatients(response.data);
    } catch (error) {
      console.error("Erro ao carregar pacientes:", error);
    }
  };

  const handleCreateAppointment = async (e) => {
    e.preventDefault();
    try {
      const patient = patients.find(p => p.id === selectedPatient);
      const appointmentData = {
        patient_id: selectedPatient,
        patient_name: patient.name,
        date: selectedDate,
        time: selectedTime
      };
      
      await axios.post(`${API}/appointments`, appointmentData);
      alert("Agendamento criado com sucesso!");
      setShowForm(false);
      setSelectedPatient("");
      setSelectedDate("");
      setSelectedTime("");
      fetchAppointments();
    } catch (error) {
      console.error("Erro ao criar agendamento:", error);
      alert("Erro ao criar agendamento");
    }
  };

  const getDaysInMonth = (date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();
    
    const days = [];
    
    // Empty cells for days before month starts
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(null);
    }
    
    // Days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(day);
    }
    
    return days;
  };

  const getAppointmentsForDay = (day) => {
    if (!day) return [];
    
    const dateStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    return appointments.filter(apt => apt.date === dateStr);
  };

  const formatDate = (date) => {
    return date.toLocaleDateString('pt-BR', { 
      year: 'numeric', 
      month: 'long' 
    });
  };

  const nextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const prevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const timeSlots = [
    "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00"
  ];

  return (
    <div className="container">
      <div className="form-header">
        <h2>📅 Agendamentos</h2>
        <button 
          onClick={() => setShowForm(!showForm)} 
          className="add-btn"
        >
          + Novo Agendamento
        </button>
      </div>

      {showForm && (
        <div className="appointment-form">
          <h3>Novo Agendamento</h3>
          <form onSubmit={handleCreateAppointment}>
            <div className="form-group">
              <label>Paciente *</label>
              <select
                value={selectedPatient}
                onChange={(e) => setSelectedPatient(e.target.value)}
                required
              >
                <option value="">Selecione um paciente</option>
                {patients.map(patient => (
                  <option key={patient.id} value={patient.id}>
                    {patient.name} - {patient.contact}
                  </option>
                ))}
              </select>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label>Data *</label>
                <input
                  type="date"
                  value={selectedDate}
                  onChange={(e) => setSelectedDate(e.target.value)}
                  required
                />
              </div>
              
              <div className="form-group">
                <label>Horário *</label>
                <select
                  value={selectedTime}
                  onChange={(e) => setSelectedTime(e.target.value)}
                  required
                >
                  <option value="">Selecione o horário</option>
                  {timeSlots.map(time => (
                    <option key={time} value={time}>
                      {time}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            
            <div className="form-actions">
              <button type="submit" className="submit-btn">
                Agendar Consulta
              </button>
              <button 
                type="button" 
                onClick={() => setShowForm(false)}
                className="cancel-btn"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      )}

      <div className="calendar-container">
        <div className="calendar-header">
          <button onClick={prevMonth} className="calendar-nav">
            ← Anterior
          </button>
          <h3>{formatDate(currentDate)}</h3>
          <button onClick={nextMonth} className="calendar-nav">
            Próximo →
          </button>
        </div>

        <div className="calendar-grid">
          <div className="calendar-weekdays">
            <div className="weekday">Dom</div>
            <div className="weekday">Seg</div>
            <div className="weekday">Ter</div>
            <div className="weekday">Qua</div>
            <div className="weekday">Qui</div>
            <div className="weekday">Sex</div>
            <div className="weekday">Sáb</div>
          </div>
          
          <div className="calendar-days">
            {getDaysInMonth(currentDate).map((day, index) => (
              <div key={index} className={`calendar-day ${day ? 'has-day' : 'empty-day'}`}>
                {day && (
                  <>
                    <span className="day-number">{day}</span>
                    <div className="day-appointments">
                      {getAppointmentsForDay(day).map(apt => (
                        <div key={apt.id} className="appointment-item">
                          <div className="appointment-time">{apt.time}</div>
                          <div className="appointment-patient">{apt.patient_name}</div>
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="appointments-list">
        <h3>Próximos Agendamentos</h3>
        {appointments.length === 0 ? (
          <p>Nenhum agendamento encontrado.</p>
        ) : (
          <div className="appointments-grid">
            {appointments
              .filter(apt => new Date(apt.date) >= new Date())
              .sort((a, b) => new Date(a.date + ' ' + a.time) - new Date(b.date + ' ' + b.time))
              .map(appointment => (
                <div key={appointment.id} className="appointment-card">
                  <h4>{appointment.patient_name}</h4>
                  <p><strong>Data:</strong> {new Date(appointment.date).toLocaleDateString('pt-BR')}</p>
                  <p><strong>Horário:</strong> {appointment.time}</p>
                  <p><strong>Status:</strong> {appointment.status}</p>
                </div>
              ))}
          </div>
        )}
      </div>
    </div>
  );
};
const Home = () => {
  return (
    <div className="container">
      <div className="home-header">
        <h1>🦶 Sistema de Podologia</h1>
        <p>Gestão completa de pacientes e fichas de anamnese</p>
      </div>
      
      <div className="home-actions">
        <Link to="/register" className="action-card">
          <div className="action-icon">📋</div>
          <h3>Cadastrar Paciente</h3>
          <p>Registrar um novo paciente no sistema</p>
        </Link>
        
        <Link to="/patients" className="action-card">
          <div className="action-icon">👥</div>
          <h3>Lista de Pacientes</h3>
          <p>Visualizar e gerenciar pacientes cadastrados</p>
        </Link>
        
        <Link to="/appointments" className="action-card">
          <div className="action-icon">📅</div>
          <h3>Agendamentos</h3>
          <p>Gerenciar consultas e horários</p>
        </Link>
        
        <Link to="/notifications" className="action-card">
          <div className="action-icon">🔔</div>
          <h3>Notificações WhatsApp</h3>
          <p>Enviar lembretes e confirmações</p>
        </Link>
        
        <Link to="/patients" className="action-card">
          <div className="action-icon">🔍</div>
          <h3>Buscar Pacientes</h3>
          <p>Encontrar e visualizar histórico de pacientes</p>
        </Link>
      </div>
    </div>
  );
};

// Navigation Component
const Navigation = () => {
  return (
    <nav className="navigation">
      <div className="nav-brand">
        <Link to="/">🦶 Podologia</Link>
      </div>
      <div className="nav-links">
        <Link to="/">Home</Link>
        <Link to="/patients">Pacientes</Link>
        <Link to="/register">Cadastrar</Link>
        <Link to="/appointments">Agendamentos</Link>
        <Link to="/notifications">Notificações</Link>
      </div>
    </nav>
  );
};

// Main App Component
function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Navigation />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/register" element={<PatientRegistration />} />
          <Route path="/patients" element={<PatientsList />} />
          <Route path="/anamnesis/:patientId" element={<AnamnesisForm />} />
          <Route path="/appointments" element={<Appointments />} />
          <Route path="/notifications" element={<Notifications />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;