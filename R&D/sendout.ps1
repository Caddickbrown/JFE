#########################################################################
# This needs some work - the Archive function isn't working as intended #
#########################################################################

# Create an Outlook application object
$outlook = New-Object -ComObject Outlook.Application

# Set the main folder containing subfolders with files
$mainFolder = "c:\Users\dcaddick-brown\OneDrive - BVI\Documents\BVI\Storage\Jrnl"

# Check if the main folder exists
if (-not (Test-Path $mainFolder)) {
    Write-Host "Error: Main folder $mainFolder not found."
    exit 1
}

# Iterate through each year folder
foreach ($yearFolder in (Get-ChildItem -Path $mainFolder -Directory)) {
    $year = $yearFolder.Name
    
    # Iterate through each month folder within the year folder
    foreach ($monthFolder in (Get-ChildItem -Path $yearFolder.FullName -Directory)) {
        $month = $monthFolder.Name

        # Iterate through each file within the month folder
        foreach ($file in (Get-ChildItem -Path $monthFolder.FullName -Filter *.txt)) {
            $fileName = $file.Name.Replace(".txt", "")
            
            # Create a new email object
            $email = $outlook.CreateItem(0)  # 0 represents olMailItem
            
            # Set email properties
            $email.Subject = "Journal Entry: $year/$month $fileName"
            $email.Body = "Journal entry for: $year/$month/$fileName"
            
            # Attach the file to the email
            $email.Attachments.Add($file.FullName)
            
            # Save as a draft without sending
            $email.Save()
            
            # Optionally display a message to confirm the draft has been saved
            Write-Host "Draft email with attachment for $year/$month/$fileName saved in Outlook."
        }
    }
}

# Set the archive folder name
$archiveFolderName = "Archive"

# Function to recursively move files and folders
function Move-FilesRecursively {
    param (
        [string]$sourcePath,
        [string]$destinationPath
    )
    
    # Move files in the current directory
    Get-ChildItem -Path $sourcePath -File | Move-Item -Destination $destinationPath

    # Recursively move subdirectories and their files
    Get-ChildItem -Path $sourcePath -Directory | ForEach-Object {
        $newDestinationPath = Join-Path -Path $destinationPath -ChildPath $_.Name
        Move-FilesRecursively -sourcePath $_.FullName -destinationPath $newDestinationPath
    }

    # Remove the source directory if it's empty after moving files
    if ((Get-ChildItem -Path $sourcePath).Count -eq 0) {
        Remove-Item -Path $sourcePath
    }
}

# Create the archive folder if it doesn't exist
$archiveFolder = Join-Path -Path $mainFolder -ChildPath $archiveFolderName
if (-not (Test-Path $archiveFolder)) {
    New-Item -ItemType Directory -Path $archiveFolder | Out-Null
}

# Iterate through each year folder
foreach ($yearFolder in (Get-ChildItem -Path $mainFolder -Directory)) {
    $year = $yearFolder.Name
    $archiveYearFolder = Join-Path -Path $archiveFolder -ChildPath $year

    # Create the year archive folder if it doesn't exist
    if (-not (Test-Path $archiveYearFolder)) {
        New-Item -ItemType Directory -Path $archiveYearFolder | Out-Null
    }

    # Move files to the year archive folder
    Move-FilesRecursively -sourcePath $yearFolder.FullName -destinationPath $archiveYearFolder

    # Remove the year folder if it's empty after archiving files
    if ((Get-ChildItem -Path $yearFolder.FullName).Count -eq 0) {
        Remove-Item -Path $yearFolder.FullName
    }

    # Optionally display a message to confirm the files have been archived for the year
    Write-Host "Files for Year $year have been successfully archived."
}

# Optionally display a message to confirm the process is complete
Write-Host "Archiving process completed successfully."


