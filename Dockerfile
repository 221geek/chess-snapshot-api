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
    stockfish \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Mettre à disposition Stockfish là où l'app le cherche
RUN mkdir -p /app/stockfish && \
    ln -s /usr/games/stockfish /app/stockfish/stockfish-16.1

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

