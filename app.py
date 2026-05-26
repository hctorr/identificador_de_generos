import streamlit as st
import librosa
import numpy as np
from tensorflow.keras.models import load_model
import matplotlib.pyplot as plt
import librosa.display

# Cargar el modelo entrenado
model = load_model('modelo_generos.h5')

# Lista de géneros en el mismo orden que el entrenamiento
genres = ['blues', 'classical', 'country', 'disco', 'hiphop', 
          'jazz', 'metal', 'pop', 'reggae', 'rock']

st.title('🎵 Identificador de Género Musical')
st.write('Sube una canción en formato .wav y el sistema identificará su género musical.')

# Subir archivo
audio_file = st.file_uploader('Sube tu canción (.wav)', type=['wav'])

if audio_file is not None:
    st.audio(audio_file, format='audio/wav')
    
    with st.spinner('Analizando la canción...'):
        # Guardar temporalmente el archivo
        with open('temp_audio.wav', 'wb') as f:
            f.write(audio_file.read())
        
        # Extraer características
        y, sr = librosa.load('temp_audio.wav')
        mfcc = librosa.feature.mfcc(y=y, sr=sr)
        mfcc = mfcc.flatten()[:25000]
        mfcc = mfcc / np.max(np.abs(mfcc))
        
        # Visualizar MFCC
        st.subheader('📊 Espectrograma MFCC')
        fig, ax = plt.subplots(figsize=(10, 4))
        librosa.display.specshow(librosa.feature.mfcc(y=y, sr=sr), 
                                  x_axis='time', sr=sr, ax=ax)
        plt.colorbar(ax.collections[0], ax=ax)
        st.pyplot(fig)
        
        # Predecir género
        input_data = mfcc.reshape(1, -1)
        prediction = model.predict(input_data)
        
        # Obtener el género con mayor probabilidad
        genre_index = np.argmax(prediction)
        genre_name = genres[genre_index]
        confidence = prediction[0][genre_index] * 100
        
        # Mostrar resultado
        st.subheader('🎸 Resultado')
        st.success(f'Género detectado: **{genre_name.upper()}**')
        st.info(f'Confianza: **{confidence:.2f}%**')
        
        # Gráfica de probabilidades
        st.subheader('📈 Probabilidad por género')
        fig2, ax2 = plt.subplots(figsize=(10, 4))
        bars = ax2.bar(genres, prediction[0] * 100, color='steelblue')
        bars[genre_index].set_color('green')
        ax2.set_ylabel('Probabilidad (%)')
        ax2.set_title('Distribución de probabilidades por género')
        plt.xticks(rotation=45)
        st.pyplot(fig2)
