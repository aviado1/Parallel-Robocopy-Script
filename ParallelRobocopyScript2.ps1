###
# Parallel Robocopy Script Without Size Features
#
# Description:
# This PowerShell script runs multiple Robocopy jobs in parallel to efficiently copy directories from 
# a source path to a destination path. It utilizes PowerShell background jobs to execute the copying 
# tasks asynchronously, ensuring maximum performance. Each Robocopy job generates a separate log file 
# for troubleshooting and verification purposes.
#
# Features:
# - Supports parallel execution of Robocopy jobs with a user-defined limit on the number of concurrent jobs.
# - Logs are generated for each job, including Robocopy output.
# - Outputs a summary of completed jobs, including source and destination paths.
#
# Requirements:
# - Ensure the source and destination paths are accessible.
# - Run the script with sufficient permissions to execute Robocopy and access the paths.
# - Robocopy must be available (it comes pre-installed on most Windows systems).
#
# Disclaimer:
# This script is provided "as is" without any warranties. Use it at your own risk.
###

# Parameters for optimization
$max_jobs = 8  # Maximum number of parallel Robocopy jobs to run simultaneously.
$threads_per_job = 32  # Number of threads per Robocopy process for faster copying.

# Source and destination directories
$src = "C:\Temp"  # Path to the source directory containing subdirectories to copy.
$dest = "D:\Temp"  # Path to the destination directory where data will be copied.

# Log folder for job-specific logs
$log = "C:\\robo\\Logs"  # Directory where job-specific logs will be stored.
if (!(Test-Path -Path $log)) { 
    mkdir $log  # Create the log directory if it doesn't exist.
}

# Get all subdirectories, including hidden ones
# Only directories are selected; files in the root of $src are not copied.
$folders = Get-ChildItem -Path $src -Directory -Force

# Check if any subdirectories are found in the source directory.
if ($folders.Count -eq 0) {
    Write-Host "No subdirectories found in $src. Exiting."
    exit
}

# Notify the user about the number of subdirectories found.
Write-Host "Found $($folders.Count) subdirectories. Starting parallel Robocopy jobs..."

# Start time for performance tracking
$tstart = Get-Date  # Record the script start time.

# Array to collect completed job outputs
$completedJobs = @()  # This array will store the results of completed jobs.

# Function to run Robocopy for a specific folder
$ScriptBlock = {
    param($folder, $src, $dest, $log, $threads_per_job)

    # Extract folder details
    $folderName = $folder.Name  # Name of the folder being copied.
    $sourcePath = Join-Path $src $folderName  # Full path to the source folder.
    $destinationPath = Join-Path $dest $folderName  # Full path to the destination folder.
    $logFile = Join-Path $log "$folderName-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"  # Log file for this job.

    # Run Robocopy with high-performance settings
    # /E - Copies all subdirectories, including empty ones.
    # /MT - Enables multithreading with the specified number of threads.
    # /R:0 - Sets the number of retries for failed copies to 0.
    # /W:0 - Sets the wait time between retries to 0 seconds.
    # /XO - Excludes older files from being overwritten.
    # /NP - Disables progress display in the console.
    # /LOG - Outputs Robocopy log to the specified file.
    robocopy $sourcePath $destinationPath /E /MT:$threads_per_job /R:0 /W:0 /XO /NP /LOG:$logFile

    # Return a completion message to the parent process.
    return "* Completed: $folderName ($sourcePath -> $destinationPath)"
}

# Process each folder in parallel
foreach ($folder in $folders) {
    # Wait if the maximum number of jobs is running.
    while ((Get-Job -State "Running").Count -ge $max_jobs) {
        Start-Sleep -Milliseconds 200  # Short sleep to avoid busy-waiting.
    }

    # Start a new Robocopy job for the current folder.
    $job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $folder, $src, $dest, $log, $threads_per_job
    Write-Host -ForegroundColor DarkYellow "Running: $($folder.Name) ($($folder.FullName))"  # Notify the user about the running job.
}

# Wait for all jobs to complete
while ((Get-Job -State "Running").Count -gt 0) {
    Start-Sleep -Seconds 1  # Check job status every second.
}

# Collect results from completed jobs
Get-Job -State "Completed" | ForEach-Object {
    $completedJobs += Receive-Job $_  # Store the output of the completed job.
    Remove-Job $_  # Clean up the completed job.
}

# End time for performance tracking
$tend = Get-Date  # Record the script end time.
$duration = New-TimeSpan -Start $tstart -End $tend  # Calculate the total duration.

# Display a summary of completed jobs
Write-Host "`nAll jobs completed in $($duration.TotalMinutes) minutes.`n" -ForegroundColor Cyan

# Display unique completion messages for all jobs.
$completedJobs | Select-Object -Unique | ForEach-Object {
    Write-Host $_ -ForegroundColor Green
}
