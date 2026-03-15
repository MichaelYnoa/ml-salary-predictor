# train.py
# Este script hace UNA cosa: toma datos, entrena un modelo, lo guarda.
# En MLOps esto se llama "training pipeline" — el primer componente de cualquier sistema ML.

import pandas as pd
from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_absolute_error
import joblib
import os

# ── 1. CARGA DE DATOS ──────────────────────────────────────────────
# Por ahora generamos datos sintéticos — sin dependencia de Kaggle.
# Semana 2 los reemplazamos con datos reales. El pipeline no cambia.

def generate_data() -> pd.DataFrame:
    """Genera dataset sintético de salarios tech."""
    import numpy as np
    np.random.seed(42)
    n = 500

    data = pd.DataFrame({
        "years_experience": np.random.randint(0, 20, n),
        "is_remote":        np.random.randint(0, 2, n),       # 0 o 1
        "company_size":     np.random.randint(1, 4, n),       # 1=small, 2=mid, 3=large
        "education_level":  np.random.randint(1, 4, n),       # 1=bach, 2=master, 3=phd
    })

    # Fórmula simple pero realista para salario base en USD
    data["salary"] = (
        40000
        + data["years_experience"] * 5000
        + data["is_remote"]        * 8000
        + data["company_size"]     * 10000
        + data["education_level"]  * 7000
        + np.random.normal(0, 5000, n)  # ruido realista
    )
    return data

# ── 2. ENTRENAMIENTO ───────────────────────────────────────────────
def train():
    df = generate_data()

    # Separamos features (X) de target (y)
    # X = lo que el modelo recibe como input
    # y = lo que el modelo tiene que predecir
    X = df.drop(columns=["salary"])
    y = df["salary"]

    # Split: 80% para entrenar, 20% para evaluar
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Normalizamos — Ridge Regression es sensible a la escala
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test  = scaler.transform(X_test)

    # Entrenamos el modelo
    model = Ridge(alpha=1.0)
    model.fit(X_train, y_train)

    # Evaluamos — MAE = error promedio en dólares
    predictions = model.predict(X_test)
    mae = mean_absolute_error(y_test, predictions)
    print(f"✅ Modelo entrenado | MAE: ${mae:,.0f}")

    # ── 3. GUARDAMOS MODELO Y SCALER ──────────────────────────────
    # Guardamos ambos — el scaler es tan importante como el modelo.
    # Si no normalizas el input en producción igual que en training → predicciones basura.
    os.makedirs("model", exist_ok=True)
    joblib.dump(model,  "model/salary_model.pkl")
    joblib.dump(scaler, "model/scaler.pkl")
    print("💾 Artefactos guardados en model/")

if __name__ == "__main__":
    train()