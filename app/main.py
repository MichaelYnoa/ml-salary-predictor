# app/main.py
# Convierte el modelo en un microservicio REST.
# En producción, esto es lo que Kubernetes escala horizontalmente
# cuando hay más requests de los que una instancia puede manejar.

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
import numpy as np
import os

app = FastAPI(
    title="Salary Predictor API",
    description="Predicts tech salaries based on experience and profile",
    version="0.1.0"
)

# ── 1. CARGA DE ARTEFACTOS ────────────────────────────────────────
# Cargamos modelo y scaler UNA vez al arrancar el servidor.
# Cargarlos en cada request sería un desastre de performance.

MODEL_PATH  = "model/salary_model.pkl"
SCALER_PATH = "model/scaler.pkl"

if not os.path.exists(MODEL_PATH):
    raise RuntimeError("Model not found. Run train.py first.")

model  = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

# ── 2. SCHEMA DE INPUT ────────────────────────────────────────────
# Pydantic valida automáticamente que el request tenga la forma correcta.
# Si falta un campo o el tipo es incorrecto → error 422 automático.
# Esto es lo que en QA llamarías "validación de contrato de API".

class SalaryRequest(BaseModel):
    years_experience: int   = Field(..., ge=0, le=40)
    is_remote:        int   = Field(..., ge=0, le=1)
    company_size:     int   = Field(..., ge=1, le=3)
    education_level:  int   = Field(..., ge=1, le=3)

class SalaryResponse(BaseModel):
    predicted_salary: float
    currency:         str = "USD"

# ── 3. ENDPOINTS ──────────────────────────────────────────────────

@app.get("/health")
def health_check():
    """
    Endpoint crítico en DevOps — Kubernetes lo usa para saber
    si el pod está vivo (liveness probe) y listo para recibir
    tráfico (readiness probe). Sin esto, el orquestador no puede
    gestionar tu servicio.
    """
    return {"status": "healthy", "model_loaded": True}

@app.post("/predict", response_model=SalaryResponse)
def predict(request: SalaryRequest):
    """Predice el salario dado un perfil técnico."""
    try:
        features = np.array([[
            request.years_experience,
            request.is_remote,
            request.company_size,
            request.education_level
        ]])

        # Aplicamos el scaler con los parámetros aprendidos en training
        # (aquí es donde el data leakage que mencionamos se volvería un bug)
        features_scaled = scaler.transform(features)
        prediction      = model.predict(features_scaled)[0]

        return SalaryResponse(predicted_salary=round(prediction, 2))

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))