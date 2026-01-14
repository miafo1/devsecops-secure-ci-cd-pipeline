#!/bin/bash

# Create reports directory
mkdir -p security/reports

echo "Starting Security Scans..."

# 1. SAST - Semgrep
echo "Running Semgrep (SAST)..."
# Ensure semgrep is installed
pip install semgrep &> /dev/null
semgrep scan --config=auto --sarif --output=security/reports/semgrep.sarif app/
# Also human readable
semgrep scan --config=auto --output=security/reports/semgrep.txt app/

# 2. Secrets - TruffleHog
echo "Running TruffleHog (Secrets)..."
# Using docker for trufflehog as it's a binary/go tool typically
docker run --rm -v "$PWD:/pwd" trufflesecurity/trufflehog:latest filesystem /pwd --json > security/reports/trufflehog.json 2>/dev/null || true

# 3. IaC - Checkov
echo "Running Checkov (IaC)..."
pip install checkov &> /dev/null
checkov -d infra/terraform --output sarif --output-file-path security/reports/checkov.sarif
checkov -d infra/terraform > security/reports/checkov.txt || true

# 4. Container/FS - Trivy
echo "Running Trivy (Container & FS)..."
# Assuming trivy is installed or we use docker. using docker to be safe if not apt-installed yet.
# FS Scan (includes SCA for python)
docker run --rm -v  "$PWD:/PWD" -w /PWD aquasec/trivy fs . --format sarif --output security/reports/trivy-fs.sarif
docker run --rm -v  "$PWD:/PWD" -w /PWD aquasec/trivy fs . > security/reports/trivy-fs.txt

# 5. SCA - OWASP Dependency Check
echo "Running OWASP Dependency Check..."
# Using docker
docker run --rm \
    --volume "$PWD:/src" \
    --volume "$PWD/security/reports:/report" \
    owasp/dependency-check:latest \
    --scan /src \
    --format "ALL" \
    --project "DevSecOps Demo" \
    --out /report

# 6. DAST - OWASP ZAP
bash scripts/dast_scan.sh
    
echo "Scans Complete. Reports are in security/reports/"
