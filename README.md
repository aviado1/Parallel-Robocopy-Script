
# Parallel Robocopy Script Without Subdirectory Analysis

## Description
This script leverages PowerShell to execute multiple **Robocopy** jobs in parallel, designed for efficient copying of directories from a source path to a destination path. It is optimized for handling scenarios involving large amounts of data, such as millions of small files. By utilizing user-defined parameters for the number of parallel jobs and threads per job, it ensures high performance. Logs are generated for each job to track the progress.

This script has been tested for copying huge datasets containing millions of small files and has proven to be very efficient.

## Features
- Executes multiple Robocopy jobs in parallel.
- User-defined number of threads per job and parallel job limit.
- Detailed logs for each job for better tracking and debugging.
- Optimized for high-performance environments.

## Prerequisites
- PowerShell (tested with PowerShell ISE for seamless execution).
- Administrative privileges to access and modify directories as needed.
- Sufficient system resources to handle parallel jobs.

## How to Use
1. **Edit Parameters**: Modify the script variables as needed:
   - `$src`: The source directory path.
   - `$dest`: The destination directory path.
   - `$max_jobs`: Maximum number of parallel Robocopy jobs.
   - `$threads_per_job`: Number of threads per Robocopy process.

   Example:
   ```powershell
   $src = "samples\source_path"
   $dest = "samples\destination_path"
   ```

2. **Run the Script**: Open the script in PowerShell ISE or your preferred PowerShell editor and execute it.

3. **Check Logs**: Logs for each job will be saved in the directory specified by the `$log` variable (default is `C:\robo\Logs`).

## Example Scenario
To copy data from `samples\source_path` to `samples\destination_path`, set:
```powershell
$src = "samples\source_path"
$dest = "samples\destination_path"
```
Then run the script. It will divide the workload across parallel Robocopy jobs for maximum efficiency.

## Differences Between Scripts
This repository contains two PowerShell scripts for executing parallel Robocopy jobs. Below are the differences:

### **1. ParallelRobocopyScript.ps1**
- **Purpose**: Original version with advanced features, including:
  - Calculation of total data size copied for each job.
  - Reporting of the number of files skipped during copying.
- **Key Features**:
  - Extracts detailed statistics (e.g., data size copied, skipped files) from Robocopy logs.
  - Displays a comprehensive summary of completed jobs with detailed information.
- **When to Use**: Ideal for scenarios where you need detailed reporting of data size and skipped files to analyze efficiency.

### **2. ParallelRobocopyScript2.ps1**
- **Purpose**: A simplified version of the script focusing on running Robocopy jobs in parallel without additional data analysis.
- **Key Features**:
  - Displays a clean summary of completed jobs, including source and destination paths.
  - Excludes data size and skipped file information for a lightweight and faster execution.
- **When to Use**: Suitable for users who prioritize simplicity and speed without requiring detailed statistics.

### Summary of Key Differences
| Feature                                  | ParallelRobocopyScript.ps1     | ParallelRobocopyScript2.ps1   |
|------------------------------------------|--------------------------------|--------------------------------|
| **Calculates Total Data Size Copied**    | ✅ Yes                         | ❌ No                         |
| **Reports Skipped Files**                | ✅ Yes                         | ❌ No                         |
| **Simplified Summary**                   | ❌ No (detailed summary)       | ✅ Yes (clean summary)         |
| **Performance Focus**                    | Moderate (due to log analysis) | High (minimal processing)      |
| **Complexity**                           | Higher (log parsing logic)     | Lower (straightforward flow)   |

## Disclaimer
This script is provided "as is" without warranty of any kind, express or implied. Use this script at your own risk. The author is not responsible for any damages or data loss resulting from its use.

## Author
This script was authored by [aviado1](https://github.com/aviado1).
