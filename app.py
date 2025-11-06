import cv2 as cv
import numpy as np

from flask import Flask, request, jsonify
from stockfish import Stockfish
from detectors.chess_position_detector import ChessPositionDetector


app = Flask(__name__)

@app.route('/')
def hello_chess_snapshot():
    return 'Hello, Chess Snapshot!'

@app.route('/api/get_chess_position', methods=['POST'])
def get_chess_position():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded', 'details': 'Send multipart/form-data with field name "image"'}), 400

    image_file = request.files['image']
    image_bytes = image_file.read()

    nparr = np.frombuffer(image_bytes, np.uint8)
    original_image = cv.imdecode(nparr, cv.IMREAD_COLOR)
    if original_image is None:
        return jsonify({'error': 'Invalid image', 'details': 'Could not decode image (unsupported/empty/corrupted).'}), 400

    try:
        chess_position_detector = ChessPositionDetector()
        fen = chess_position_detector.detect(original_image)
        return jsonify({'fen': fen})
    except Exception as e:
        return jsonify({'error': 'Detection failed', 'details': str(e)}), 500

@app.route('/api/get_best_move', methods=['POST'])
def get_best_move():
    data = request.get_json(silent=True) or {}
    fen = data.get('fen')
    if not fen:
        return jsonify({'error': 'Missing field', 'details': 'Provide JSON body with key "fen"'}), 400

    try:
        stockfish = Stockfish(path='./stockfish/stockfish-16.1')
        stockfish.set_fen_position(fen)
        best_move = stockfish.get_best_move()
        return jsonify({'best_move': best_move})
    except Exception as e:
        return jsonify({'error': 'Engine failed', 'details': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
