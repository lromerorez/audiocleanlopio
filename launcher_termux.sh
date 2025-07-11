#!/data/data/com.termux/files/usr/bin/bash

SPLEETER_VENV_NAME=".venv"
AUDIO_PROCESSOR_SCRIPT="audio_processor.py"

# Ruta al Python del entorno virtual
VENV_PYTHON="$PWD/$SPLEETER_VENV_NAME/bin/python"

# Función para configurar el almacenamiento de Termux
setup_termux_storage() {
  echo "Configurando acceso al almacenamiento externo de Termux..."
  termux-setup-storage
  echo "Por favor, concede los permisos de almacenamiento si se te solicitan."
  echo "Esto es necesario para que Spleeter acceda a tus archivos de audio."
  sleep 3
}

# Barra de progreso
show_progress() {
  local total=$1
  local current=$2
  local width=50
  local progress=$((current * width / total))
  local percent=$((current * 100 / total))
  local bar=""
  for ((i=0; i<progress; i++)); do bar+="#"; done
  for ((i=progress; i<width; i++)); do bar+="-"; done
  printf "\r[%s] %d%% (%d/%d)" "$bar" "$percent" "$current" "$total"
}

# Lanzador
run_audio_processor() {
  source "$SPLEETER_VENV_NAME/bin/activate"
  echo "Ejemplos de rutas en Termux:"
  echo "  - Archivos en la memoria interna (descargas, música): /sdcard/Music/MisAudios"
  echo "  - Archivos en la carpeta de Termux: $PWD/mis_audios"
  read -p "Ingresa ruta a archivo o carpeta de audio: " input_path
  echo "Iniciando procesamiento de audio..."
  
  total=$("$VENV_PYTHON" "$AUDIO_PROCESSOR_SCRIPT" --count "$input_path")
  count=0

  "$VENV_PYTHON" "$AUDIO_PROCESSOR_SCRIPT" "$input_path" | while read -r line; do
    if [[ "$line" == *"[PROGRESS]"* ]]; then
      count=$((count + 1))
      show_progress $total $count
    else
      echo "$line"
    fi
  done
  echo -e "\nProcesamiento finalizado."
  deactivate
}

# Menú principal
echo "=== VocalClarity Launcher (Termux) ==="
echo "1. Instalar dependencias"
echo "2. Procesar archivo o carpeta (modo forense)"
echo "3. Salir"
read -p "Selecciona una opción [1-3]: " option

case $option in
  1)
    echo "Instalando dependencias del sistema para Termux..."
    setup_termux_storage # Ejecutar configuración de almacenamiento primero
    pkg update && pkg upgrade -y
    pkg install ffmpeg sox python python-pip python-virtualenv -y # python-pip para asegurar pip, python-virtualenv para venv
    
    echo "Creando entorno virtual..."
    python -m venv "$SPLEETER_VENV_NAME" # Usar 'python' que apunta a python3 en Termux
    source "$SPLEETER_VENV_NAME/bin/activate"
    pip install --upgrade pip
    pip install spleeter
    deactivate
    echo "Entorno y dependencias listas."
    echo "Reinicia Termux o el script si tuviste problemas con 'termux-setup-storage'."
    ;;
  2)
    if [ ! -x "$VENV_PYTHON" ]; then
      echo "Error: entorno virtual no encontrado. Ejecuta primero la opción 1."
      exit 1
    fi
    run_audio_processor
    ;;
  3)
    echo "Saliendo..."
    exit 0
    ;;
  *)
    echo "Opción inválida."
    ;;
esac