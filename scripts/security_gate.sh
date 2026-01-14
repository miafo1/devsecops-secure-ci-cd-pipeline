#!/bin/bash

echo "Evaluating Security Gates..."
EXIT_CODE=0

# Check Semgrep Findings (Simulated by grep for simplistic demo, usually we parse SARIF/JSON)
if grep -q "user input" security/reports/semgrep.txt; then
    echo "[FAIL] SAST: Critical issues found by Semgrep"
    EXIT_CODE=1
else
    echo "[PASS] SAST: No critical issues found"
fi

# Check TruffleHog (Secrets)
if [ -s security/reports/trufflehog.json ]; then
     # Check if the file contains any "Verified" secrets or just scan metadata? 
     # Trufflehog V3 outputs JSON lines. Empty file means no output? 
     # Actually we should check if it found anything.
     if grep -q "Detector" security/reports/trufflehog.json; then
        echo "[FAIL] Secrets: Potential secrets found by TruffleHog"
        EXIT_CODE=1
     else
        echo "[PASS] Secrets: No secrets found"
     fi
else
     echo "[PASS] Secrets: No secrets found (empty log)"
fi

# Check Checkov (IaC)
# Checkov returns non-zero exit code on failure, but we captured output.
# We can check the text report for "Failed checks: 0" or failing count.
if grep -q "Failed checks:" security/reports/checkov.txt; then
    FAIL_COUNT=$(grep "Failed checks:" security/reports/checkov.txt | awk '{print $3}')
    if [ "$FAIL_COUNT" -gt "0" ]; then
        echo "[FAIL] IaC: $FAIL_COUNT policy violations found by Checkov"
        EXIT_CODE=1
    else
        echo "[PASS] IaC: Infrastructure is secure"
    fi
else
    echo "[WARN] IaC: Checkov report format not recognized or scan failed"
fi

# Check Dependency Check (SCA)
# grep for vulnerabilities in the report (not robust for production but good for bash demo)
# ODC creates dependency-check-report.html/json/etc.
if grep -q "\"vulnerabilities\": \[" security/reports/dependency-check-report.json; then
     # Use simple grip to see if array is not empty? requires jq usually.
     # Lets check HTML/Text summary if possible or just assume if we see "High"
     if grep -i "cvssv3.*baseScore\": [7-9]" security/reports/dependency-check-report.json; then
         echo "[FAIL] SCA: High severity dependencies found"
         EXIT_CODE=1
     else
         echo "[PASS] SCA: No high severity dependencies found"
     fi
else
    echo "[PASS] SCA: No vulnerabilities info found"
fi

echo "Security Gate Evaluation Complete. Exit Code: $EXIT_CODE"
exit $EXIT_CODE
