import os
import sys
from spleeter.separator import Separator

def count_audio_files(path):
    """Cuenta cuántos archivos de audio hay."""
    if os.path.isfile(path):
        return 1
    count = 0
    for root, dirs, files in os.walk(path):
        count += sum(1 for f in files if f.lower().endswith(('.mp3', '.wav', '.flac')))
    return count

def enhance_audio(file_path):
    print(f"[PROGRESS] Procesando: {file_path}")
    try:
        # Spleeter intenta descargar modelos si no los encuentra.
        # Asegúrate de tener conexión a internet la primera vez.
        separator = Separator('spleeter:2stems')
        # La carpeta 'output' se creará en el directorio actual (donde ejecutas el script)
        separator.separate_to_file(file_path, output_path="output")
    except Exception as e:
        print(f"[ERROR] Falló {file_path}: {e}")

def process_path(path):
    if os.path.isfile(path):
        enhance_audio(path)
    elif os.path.isdir(path):
        for root, dirs, files in os.walk(path):
            for f in files:
                if f.lower().endswith(('.mp3', '.wav', '.flac')):
                    enhance_audio(os.path.join(root, f))
    else:
        print("[ERROR] Ruta inválida.")

if __name__ == "__main__":
    if "--count" in sys.argv:
        if len(sys.argv) < 3:
            print(0)
            sys.exit(1)
        print(count_audio_files(sys.argv[2]))
        sys.exit(0)

    if len(sys.argv) < 2:
        print("Uso: python audio_processor.py <archivo|carpeta>")
        sys.exit(1)

    path = sys.argv[1]
    process_path(path)