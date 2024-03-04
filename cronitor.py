import os
import subprocess
import cronitor
import requests

# Set the global variable for CRONITOR_API_KEY
CRONITOR_API_KEY = os.environ.get('CRONITOR_API_KEY')

monitor_url = 'https://cronitor.io/api/monitors'

# Step 1: Export Cronitor_API_KEY

cronitor_api_key = os.getenv('CRONITOR_API_KEY')

if not cronitor_api_key:
    print("CRONITOR_API_KEY is not set. Please set it before running this script.")
    exit(1)

def list_crontab_jobs():
    # Run 'crontab -l' command to get the user's crontab
    crontab_output = subprocess.run(['crontab', '-l'], capture_output=True, text=True)

    if "no crontab for" in crontab_output.stderr:
        print(crontab_output.stderr.strip()) # Print the actual crontab message
    else:
        # Split the output into lines to get the invidual cron jobs
        crontab_lines = crontab_output.stdout.split('\n')

        # Print each cron job
        for job in crontab_lines:
            print(job)

def list_monitors(api_key):
    try:
        # Make a GET request to list monitors
        response = requests.get(monitor_url, auth=(api_key, ''))

        # Check if the request was successful (HTTP status code 200)
        if response.status_code == 200:
            monitors = response.json()
            if "monitors" in monitors:
                if monitors["monitors"]:
                    for monitor in monitors["monitors"]:
                        print(f"Monitor Key: {monitor['key']} - Name: {monitor.get('name', 'N/A')}")
                else:
                    print("No monitors found.")
            else:
                print("Error: Invalid response from Cronitor API.")

        else:
            print(f"Error: Unable to list monitors. Status code: {response.status_code}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # List all crontab jobs
    list_crontab_jobs()

    # List all cronitor monitors
    if not cronitor_api_key:
        print("Error: Cronitor API key is not set. Set the CRONITOR_API_KEY environment variable before running this script.")
    else:
        list_monitors(cronitor_api_key)
