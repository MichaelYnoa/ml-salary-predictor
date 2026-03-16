# Dockerfile

# ── 1. BASE IMAGE ─────────────────────────────────────────────────
# Partimos de una imagen oficial de Python.
# "slim" = versión mínima sin herramientas innecesarias.
# Menos peso → más rápido de descargar y desplegar en producción.
FROM python:3.11-slim

# ── 2. DIRECTORIO DE TRABAJO ──────────────────────────────────────
# Todos los comandos siguientes se ejecutan desde aquí dentro
# del container. Equivale a hacer "cd /app" pero de forma permanente.
WORKDIR /app

# ── 3. DEPENDENCIAS PRIMERO ───────────────────────────────────────
# Copiamos SOLO requirements.txt antes que el resto del código.
# Por qué: Docker cachea cada paso. Si el código cambia pero
# requirements.txt no, Docker reutiliza el cache de dependencias
# y el build es 10x más rápido. Esto importa mucho en CI/CD.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── 4. CÓDIGO Y ARTEFACTOS ────────────────────────────────────────
# Copiamos el código de la app y el modelo entrenado.
# El modelo va dentro del container para que la API pueda cargarlo.
COPY app/ ./app/
COPY model/ ./model/

# ── 5. PUERTO ─────────────────────────────────────────────────────
# Documentamos que el container escucha en el puerto 8000.
# EXPOSE no abre el puerto — eso lo hace el comando docker run.
# Es documentación para otros developers y para orquestadores
# como Kubernetes que necesitan saber qué puerto mapear.
EXPOSE 8000

# ── 6. COMANDO DE ARRANQUE ────────────────────────────────────────
# Lo que se ejecuta cuando el container arranca.
# "--host 0.0.0.0" es crítico: sin esto uvicorn solo escucha
# dentro del container y nunca llegarías a la API desde afuera.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]