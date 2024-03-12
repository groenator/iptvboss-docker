import os
import subprocess
import requests
import argparse
import re

CRONITOR_API_KEY = os.getenv('CRONITOR_API_KEY')
MONITOR_URL = 'https://cronitor.io/api/monitors'

def get_cronitor_api_key():
    if not CRONITOR_API_KEY:
        print("CRONITOR_API_KEY is not set. Please set it before running this script.")
        exit(1)
    return CRONITOR_API_KEY

def list_crontab_jobs():
    crontab_output = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
    if crontab_output.returncode != 0:
        print("Error listing crontab jobs.")
        return []
    return [line for line in crontab_output.stdout.splitlines() if line and not line.startswith('#')]

def list_monitors(api_key):
    try:
        response = requests.get(MONITOR_URL, auth=(api_key, ''))
        response.raise_for_status()
        monitors = response.json().get("monitors", [])
        return monitors
    except requests.exceptions.RequestException as e:
        print(f"Error: Unable to list monitors. {e}")
        return []

def get_monitor_name(monitors, monitor_name):
    for monitor in monitors:
        if monitor.get('name') == monitor_name:
            return monitor
    return None

def create_monitor(api_key, cron_schedule, command, name):
    try:
        data = {
            "type": "job",
            "schedule": cron_schedule,
            "name": name,
            "command": command,
            "platform": "Linux cron"
        }
        response = requests.post(MONITOR_URL, auth=(api_key, ''), json=data)
        response.raise_for_status()
        monitor_id = response.json().get("key")
        print(f"Created monitor with key: {monitor_id}")
        return monitor_id
    except requests.exceptions.RequestException as e:
        print(f"Error: Unable to create monitor. {e}")
        if 'response' in locals() and response.status_code == 400:
            print(f"Details: {response.json()}")
        return None

def delete_monitor(api_key, monitor_id):
    try:
        url = f"{MONITOR_URL}/{monitor_id}"
        response = requests.delete(url, auth=(api_key, ''))
        response.raise_for_status()
        print(f"Deleted monitor with ID: {monitor_id}")
    except requests.exceptions.RequestException as e:
        print(f"Error: Unable to delete monitor. {e}")
        if 'response' in locals() and response.status_code == 404:
            print(f"Monitor with ID {monitor_id} does not exist or has already been deleted.")
        elif 'response' in locals():
            print(f"Details: {response.text}")

def update_crontab_with_monitor(job, monitor_id):
    # Generate the new job line with the monitor ID
    job_parts = job.split()
    cron_schedule = ' '.join(job_parts[:5])
    command = ' '.join(job_parts[5:])
    new_job_line = f"{cron_schedule} cronitor exec {monitor_id} {command}"

    # Get the current crontab, excluding the job we're updating
    current_jobs = list_crontab_jobs()
    current_jobs = [line for line in current_jobs if line != job]

    # Add the new job line
    current_jobs.append(new_job_line)

    # Write the updated crontab
    new_crontab = "\n".join(current_jobs) + "\n"
    process = subprocess.run(['crontab', '-'], input=new_crontab, text=True, capture_output=True)
    if process.returncode != 0:
        print(f"Error updating crontab: {process.stderr}")
    else:
        print(f"Updated crontab with monitor ID: {monitor_id}")

def parse_arguments():
    parser = argparse.ArgumentParser(description='Create and update Cronitor monitors for cron jobs.')
    parser.add_argument('--name', type=str, help='The name for the new monitor.')
    return parser.parse_args()

def get_monitor_id_from_job(job):
    match = re.search(r'cronitor exec ([\w-]+)', job)
    return match.group(1) if match else None

def remove_cronitor_exec_from_job(job):
    return re.sub(r'cronitor exec [\w-]+\s*', '', job)

if __name__ == "__main__":
    args = parse_arguments()
    monitor_name = args.name

    if not monitor_name:
        print("Error: Please provide a name for the monitor using the --name argument.")
        exit(1)

    cronitor_api_key = get_cronitor_api_key()
    local_crontab_jobs = list_crontab_jobs()
    cronitor_monitors = list_monitors(cronitor_api_key)

     # This dictionary will map monitor names to their IDs
    existing_monitors = {monitor['name']: monitor['key'] for monitor in cronitor_monitors}

    for job in local_crontab_jobs:
        monitor_id = get_monitor_id_from_job(job)
        job_without_monitor = remove_cronitor_exec_from_job(job)
        should_create_monitor = True

    if monitor_name in existing_monitors:
        existing_monitor_id = existing_monitors[monitor_name]
        if monitor_id == existing_monitor_id:
            print(f"Monitor named '{monitor_name}' with ID {monitor_id} already exists for this job, no action needed.")
            should_create_monitor = False
        else:
            print(f"Monitor named '{monitor_name}' exists but with a different ID. Updating the crontab with the correct monitor ID.")
            update_crontab_with_monitor(job_without_monitor, existing_monitor_id)
            if monitor_id:
                delete_monitor(cronitor_api_key, monitor_id)
            should_create_monitor = False

    if should_create_monitor:
        # No monitor with the given name exists or the monitor ID in the job does not match. # Create a new monitor and update the crontab
        print(f"Creating a new monitor named '{monitor_name}'.")
        job_parts = job_without_monitor.split()
        cron_schedule = ' '.join(job_parts[:5])
        command = ' '.join(job_parts[5:])
        new_monitor_id = create_monitor(cronitor_api_key, cron_schedule, command, monitor_name)
        if new_monitor_id:
            update_crontab_with_monitor(job_without_monitor, new_monitor_id)
