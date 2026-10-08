# 🎵 Clasificador de géneros musicales

Aplicación web que clasifica una canción en uno de los 10 géneros del dataset GTZAN usando una red neuronal (MLP) entrenada con TensorFlow/Keras, desplegada con Streamlit y Docker.

## Problema

Clasificar automáticamente un clip de audio según su género musical a partir de sus características acústicas.

## Dataset

[GTZAN](https://www.kaggle.com/datasets/andradaolteanu/gtzan-dataset-music-genre-classification): 1000 fragmentos de 30 segundos, repartidos en 10 géneros (100 por género).

## Método

1. **Extracción de características:**  MFCC, chroma, centroide espectral...
2. **Preprocesado:** normalización, división train/test, etc.
3. **Modelo:** perceptrón multicapa (MLP) con TensorFlow/Keras. [Capas, neuronas, activaciones, dropout, optimizador...].
4. **Despliegue:** interfaz con Streamlit empaquetada en un contenedor Docker.

## Resultados

| Métrica | Valor |
|---|---|
| Accuracy en test | 57,50 % |

## Limitaciones

- El dataset es pequeño (1000 clips), lo que limita la capacidad de generalizar.
- Un MLP sobre características extraídas pierde información temporal del audio.

## Posibles mejoras

- Usar una CNN sobre espectrogramas en lugar de características agregadas.
- Aumento de datos (data augmentation) para audio.

## Cómo ejecutarlo

### Con Docker

```bash
docker build -t clasificador-generos .
docker run -p 8501:8501 clasificador-generos
```

Abre http://localhost:8501 en el navegador.

### En local

```bash
git clone [url-del-repositorio]
cd [nombre-del-repositorio]
pip install -r requirements.txt
streamlit run app.py
```

## Estructura del proyecto

```
├── app.py
├── modelo_generos.h5
├── docker-compose.yml
├── requirements.txt
└── Dockerfile
```

## Tecnologías

Python · TensorFlow/Keras · Streamlit · Docker

## Autor

**Héctor Ruiz** · [GitHub](https://github.com/hctorr) · [LinkedIn](https://www.linkedin.com/in/hectorruizgaldon/)
