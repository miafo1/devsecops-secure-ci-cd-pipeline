import os

def connect_to_aws():
    # HARDCODED SECRET - TruffleHog should catch this
    aws_access_key = "AKIA1234567890EXAMPLE"
    aws_secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    print(f"Connecting with {aws_access_key}")

def unsafe_execution(user_input):
    # UNSAFE FUNCTION - Semgrep should catch this
    eval(user_input)

if __name__ == "__main__":
    connect_to_aws()
