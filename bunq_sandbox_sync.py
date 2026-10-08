#!/usr/bin/env python3
# ==============================================================================
# Script Name: bunq_sandbox_sync.py
# Description: Configures and exports Bunq Sandbox API integration parameters
#              aligned with namespace NN and evergreen telemetry.
# ==============================================================================

import os
import json

def generate_bunq_config():
    output_dir = "MOSFETQexchange/output"
    os.makedirs(output_dir, exist_ok=True)
    
    config_data = {
        "gateway_type": "Bunq Sandbox API v1",
        "api_endpoint": "https://public-api.sandbox.bunq.com/v1/",
        "settlement_reference": "https://bunq.me/9783000684630",
        "namespace": "NN",
        "author": "Kai Olaf Ketelhut",
        "orcid": "0000-0001-6049-8873",
        "station_coordinates": "52.5200° N, 13.4050° E (Berlin)",
        "axiom_constraint": "1 + 0 = 1",
        "status": "Active Sandbox Linkage"
    }
    
    output_path = os.path.join(output_dir, "bunq_sandbox_config.json")
    with open(output_path, "w") as f:
        json.dump(config_data, f, indent=4)
        
    print(f"[+] Bunq Sandbox configuration generated at: {output_path}")

if __name__ == "__main__":
    generate_bunq_config()
