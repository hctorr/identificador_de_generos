# ─────────────────────────────────────────────────────────────────────────────
# Dockerfile — Sistema de Identificación del Género Musical (P05)
# Host: Alpine Linux VM con Docker
# Contenedor: python:3.11-slim (Debian) — necesario para TensorFlow + librosa
# ─────────────────────────────────────────────────────────────────────────────

# 1. Imagen base: Python 3.11 slim (Debian Bookworm)
#    No usamos Alpine dentro del contenedor porque TensorFlow no tiene
#    wheels precompilados para musl/Alpine y compilarlo tarda horas.
FROM python:3.11-slim

# 2. Metadatos
LABEL maintainer="P05 - UPV Campus d'Alcoi"
LABEL description="Clasificador de géneros musicales con Streamlit y TensorFlow"

# 3. Variables de entorno
#    - Evita que Python genere archivos .pyc (innecesarios en contenedor)
#    - Fuerza salida sin buffer (logs visibles en tiempo real)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0
ENV STREAMLIT_BROWSER_GATHER_USAGE_STATS=false

# 4. Dependencias del sistema necesarias para librosa y audio
#    libsndfile1   → lectura de archivos .wav con librosa
#    libgl1        → dependencia de OpenCV (aunque no la usemos, evita errores)
#    libglib2.0-0  → dependencia de sistema para varios paquetes Python
#    ffmpeg        → soporte de formatos de audio adicionales
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 5. Directorio de trabajo dentro del contenedor
WORKDIR /app

# 6. Copiar e instalar dependencias Python PRIMERO
#    (capa separada → si solo cambia el código, esta capa se reutiliza del caché)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 7. Copiar el resto del código y el modelo
COPY app.py .
COPY modelo_generos.h5 .

# 8. Puerto que expone Streamlit
EXPOSE 8501

# 9. Healthcheck: verifica que la app responde
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# 10. Comando de arranque
CMD ["streamlit", "run", "app.py", \
     "--server.port=8501", \
     "--server.address=0.0.0.0", \
     "--server.headless=true"]
