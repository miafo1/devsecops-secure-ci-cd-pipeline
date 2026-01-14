# Codespaces-Native DevSecOps CI/CD Pipeline

This project demonstrates a production-grade DevSecOps CI/CD pipeline designed to run entirely within GitHub Codespaces and GitHub Actions, adhering to strict enterprise security constraints.

## 🎯 Project Objective
Design and implement a secure CI/CD pipeline that:
- Runs inside GitHub Codespaces (Ubuntu/Debian).
- Uses GitHub Actions for CI/CD.
- Performs security testing locally (PRE-COMMIT) and remotely (CI).
- Enforces security gates regarding SAST, SCA, Secrets, IaC, and Container Security.

## 🏗 Architecture & Toolchain

### Execution Environment
- **Development**: GitHub Codespaces (Non-privileged Docker, Python venv).
- **CI/CD**: GitHub Actions (ubuntu-latest).
- **Cloud**: AWS (Free Tier) - ECR, IAM.

### Security Toolchain
| Category | Tool | Scope |
|----------|------|-------|
| **SAST** | Semgrep | Code Quality & Security |
| **SCA** | OWASP Dependency-Check | Vulnerable Dependencies |
| **Secrets** | TruffleHog | Hardcoded Secrets |
| **IaC** | Checkov | Terraform Misconfigurations |
| **Container** | Trivy | Docker Image Scanning |
| **DAST** | OWASP ZAP | Runtime Web Scanning |

## 🚀 Getting Started

### Prerequisites
- GitHub Codespaces or a Linux-based environment with Docker and Python 3.
- AWS Credentials (if deploying for real).

### Local Execution (Codespace)
The pipeline is designed to be tested locally before pushing code.

1. **Install Dependencies**:
    ```bash
    pip install -r app/backend/requirements.txt
    ```

2. **Run All Security Scans**:
   This script orchestrates Semgrep, TruffleHog, Checkov, Trivy, and ZAP.
    ```bash
    bash scripts/local_scan.sh
    ```
    *Artifacts are saved to `security/reports/`.*

3. **Verify Security Gates**:
   Check if the build would pass or fail based on current findings.
    ```bash
    bash scripts/security_gate.sh
    ```

### CI/CD Pipeline
The GitHub Actions workflow (`.github/workflows/devsecops-pipeline.yml`) automatically runs on push/PR.
1. **Security Scan Job**: Runs identical tools to local scan.
2. **Build Job**: Builds Docker image if scans pass.
3. **Deploy Job**: Deploys to AWS (Mocked/Actual).

## 🔒 Security Gate Logic
The pipeline will **FAIL** if:
- **SAST**: Semgrep finds critical issues (e.g., `eval()`).
- **Secrets**: TruffleHog detects any secrets.
- **IaC**: Checkov finds failed checks.
- **SCA**: High severity vulnerabilities are found.

## 🧪 Demo Scenario
The repository comes pre-loaded with intentional vulnerabilities to demonstrate the gates:
- `app/backend/insecure_example.py`: Contains hardcoded secrets and `eval()`.
- `app/backend/requirements.txt`: Contains vulnerable library versions.
- `infra/terraform/security.tf`: Opens port 22 to 0.0.0.0/0.

**To Fix:**
1. Remove `insecure_example.py` or fix the code.
2. Update `requirements.txt` to safe versions.
3. Restrict security group ingress in `security.tf`.

## 💰 Cost Control
- Uses **AWS Free Tier** eligible resources.
- `mock` deployment avoids spinning up real EKS clusters unless configured.
- **Teardown**: Run `terraform destroy` in `infra/terraform/` if any resources were created.
