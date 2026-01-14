FROM python:3.7-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Running as root (Trivy should complain if configured to check for non-root)
CMD ["python", "app.py"]
