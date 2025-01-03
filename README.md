# System Monitoring Script

This Bash script monitors system resources such as disk usage, CPU usage, and memory usage. It provides warnings when certain thresholds are exceeded and logs the system statistics to a specified file. Additionally, it sends email alerts for critical disk usage levels.

## Features
- Monitors disk usage and warns if it exceeds a specified threshold.
- Logs CPU usage percentage and highlights high usage.
- Tracks memory usage and displays total, used, and free memory.
- Lists the top 5 memory-consuming processes.
- Sends email alerts for critical disk usage.

## Requirements
- Bash shell
- `msmtp` configured for sending emails
- Utilities: `awk`, `df`, `sed`, `grep`, `head`, `ps`, `free`

## Usage
Run the script with optional parameters for the log file path and disk usage threshold:
```bash
./state.sh [LOG_FILE] [THRESHOLD]
