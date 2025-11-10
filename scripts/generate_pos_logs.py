#!/usr/bin/env python3
import os
import time
import random
import subprocess
from datetime import datetime

LOG_DIR = "/tmp/pos-logs"
LOG_FILE = os.path.join(LOG_DIR, "pos-core.log")
LOG_LEVELS = ["INFO", "WARN", "ERROR"]
PAYMENT_METHODS = ["cash", "credit_card", "mobile"]

# Discover running POS containers (names starting with 'pos')
def get_pos_containers():
    result = subprocess.run([
        "docker", "ps", "--format", "{{.Names}}"
    ], capture_output=True, text=True)
    names = result.stdout.strip().split("\n")
    return [n for n in names if n.startswith("pos")]

# Generate a random log line for a POS node
def generate_log(pos_id, problem_mode=False):
    now = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    lines = []
    # Always generate a transaction event
    amount = random.uniform(1, 200)
    lines.append(f"{now} [INFO] POS terminal {pos_id} started new transaction: ${amount:.2f}")
    # Randomly decide if transaction is successful or failed
    if random.random() < (0.15 if problem_mode else 0.02):
        lines.append(f"{now} [ERROR] POS terminal {pos_id}: Payment gateway timeout")
    else:
        lines.append(f"{now} [INFO] POS terminal {pos_id}: Transaction completed successfully")
    # Randomly add payment method
    if random.random() < 0.8:
        method = random.choice(PAYMENT_METHODS)
        lines.append(f"{now} [INFO] POS terminal {pos_id}: Payment method: {method}")
    # Randomly add warnings
    if random.random() < (0.2 if problem_mode else 0.05):
        lines.append(f"{now} [WARN] POS terminal {pos_id}: Printer out of paper")
    if random.random() < (0.1 if problem_mode else 0.03):
        lines.append(f"{now} [WARN] POS terminal {pos_id}: Slow network detected")
    # Randomly add more errors in problem mode
    if problem_mode and random.random() < 0.1:
        lines.append(f"{now} [ERROR] POS terminal {pos_id}: Card reader failure")
    return lines

def main():
    os.makedirs(LOG_DIR, exist_ok=True)
    print("Starting real-time POS log generator. Press Ctrl+C to stop.")
    try:
        while True:
            pos_nodes = get_pos_containers()
            all_lines = []
            for pos_name in pos_nodes:
                # Determine if this node is in problem mode (pos4 as example)
                problem_mode = (pos_name == "pos4")
                lines = generate_log(pos_name.upper(), problem_mode)
                all_lines.extend(lines)
            if all_lines:
                with open(LOG_FILE, "a") as f:
                    for line in all_lines:
                        f.write(line + "\n")
            time.sleep(random.uniform(0.5, 2.0))  # Random interval for realism
    except KeyboardInterrupt:
        print("\nLog generation stopped.")

if __name__ == "__main__":
    main()
