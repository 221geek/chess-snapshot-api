# Utiliser Python 3.10 comme image de base
FROM python:3.10-slim

# Définir le répertoire de travail
WORKDIR /app

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    wget \
    ca-certificates \
    unzip \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Télécharger et installer Stockfish pour Linux
RUN mkdir -p /app/stockfish && \
    wget https://github.com/official-stockfish/Stockfish/releases/download/sf_16.1/stockfish_16.1_linux_x64_avx2.zip -O /tmp/stockfish.zip && \
    unzip /tmp/stockfish.zip -d /tmp/ && \
    mv /tmp/stockfish_16.1_linux_x64_avx2/stockfish_16.1_linux_x64_avx2 /app/stockfish/stockfish-16.1 && \
    chmod +x /app/stockfish/stockfish-16.1 && \
    rm -rf /tmp/stockfish.zip /tmp/stockfish_16.1_linux_x64_avx2

# Copier le fichier requirements.txt
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copier tous les fichiers de l'application
COPY . .

# Exposer le port 8080
EXPOSE 8080

# Commande pour lancer l'application
CMD ["python", "app.py"]

