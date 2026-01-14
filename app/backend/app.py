from flask import Flask, request, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the DevSecOps Demo App!"

@app.route('/health')
def health():
    return jsonify(status="healthy"), 200

@app.route('/user/<username>')
def get_user(username):
    # Use parameterized query (simulation) to avoid SQL injection
    query = "SELECT * FROM users WHERE username = %s"
    params = (username,)
    # Return structured JSON to avoid XSS via formatted strings
    return jsonify(executed_query=query, params=params), 200

if __name__ == '__main__':
    # Bind to localhost for local scans to avoid exposing dev server publicly
    app.run(host='127.0.0.1', port=5000)
