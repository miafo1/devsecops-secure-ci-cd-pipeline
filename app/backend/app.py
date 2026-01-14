from flask import Flask, request, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the DevSecOps Demo App!"

@app.route('/health')
def health():
    return jsonify(status="healthy"), 200

# Intentional SQL Injection vulnerability (Simulated)
@app.route('/user/<username>')
def get_user(username):
    # This is a simulated vulnerability for Semgrep to find
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    return f"Executed query: {query}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
