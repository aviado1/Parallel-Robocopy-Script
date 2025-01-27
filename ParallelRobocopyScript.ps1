###
# Parallel Robocopy Script Without Subdirectory Analysis
#
# Description:
# This script uses PowerShell to execute multiple Robocopy jobs in parallel for efficient copying of directories 
# from a source path to a destination path. It optimizes performance using user-defined parameters for the number 
# of parallel jobs and threads per job. Logs are created for each job to track its progress.
#
# Disclaimer:
# This script is provided "as is" without warranty of any kind, express or implied, including but not limited to 
# the warranties of merchantability, fitness for a particular purpose, and noninfringement. Use this script at your 
# own risk. The author is not responsible for any damages or data loss resulting from the use of this script.
###

# Parameters for optimization
$max_jobs = 8  # Number of parallel robocopy jobs
$threads_per_job = 32  # Threads per robocopy process

# Source and destination directories
$src = "samples\\source_path"
$dest = "samples\\destination_path"

# Log folder for job-specific logs
$log = "C:\\robo\\Logs"
if (!(Test-Path -Path $log)) { mkdir $log }

# Get all subdirectories directly (no analysis)
$folders = Get-ChildItem -Path $src -Directory

if ($folders.Count -eq 0) {
    Write-Host "No subdirectories found in $src. Exiting."
    exit
}

Write-Host "Found $($folders.Count) subdirectories. Starting parallel Robocopy jobs..."

# Start time for performance tracking
$tstart = Get-Date

# Function to run Robocopy for a specific folder
$ScriptBlock = {
    param($folder, $src, $dest, $log, $threads_per_job)
    $folderName = $folder.Name
    $sourcePath = Join-Path $src $folderName
    $destinationPath = Join-Path $dest $folderName
    $logFile = Join-Path $log "$folderName-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

    # Run Robocopy with high-performance settings
    robocopy $sourcePath $destinationPath /E /MT:$threads_per_job /R:0 /W:0 /XO /NP > $logFile

    Write-Host "Completed: $folderName"
}

# Process each folder in parallel
foreach ($folder in $folders) {
    # Wait if the maximum number of jobs is running
    while ((Get-Job -State "Running").Count -ge $max_jobs) {
        Start-Sleep -Milliseconds 200
    }

    # Clean up completed jobs dynamically
    Get-Job -State "Completed" | Receive-Job | Out-Null
    Remove-Job -State "Completed"

    # Start a new Robocopy job for the folder
    Start-Job -ScriptBlock $ScriptBlock -ArgumentList $folder, $src, $dest, $log, $threads_per_job
}

# Wait for all jobs to complete
while ((Get-Job -State "Running").Count -gt 0) {
    Start-Sleep -Seconds 1
}

# Cleanup completed jobs
Get-Job -State "Completed" | Receive-Job | Out-Null
Remove-Job -State "Completed"

# End time for performance tracking
$tend = Get-Date
$duration = New-TimeSpan -Start $tstart -End $tend

Write-Host "All jobs completed in $($duration.TotalMinutes) minutes."

# Uploading the script to GitHub
# Replace with your GitHub repository details
$repoPath = "C:\\path_to_local_repo"
$scriptFileName = "ParallelRobocopyScript.ps1"
$scriptPath = Join-Path $repoPath $scriptFileName

# Save the script to the repository
Set-Content -Path $scriptPath -Value (Get-Content -Path $MyInvocation.MyCommand.Definition)

# Git commands
Set-Location -Path $repoPath
& git add $scriptFileName
& git commit -m "Add Parallel Robocopy Script with description and disclaimer"
& git push origin main
