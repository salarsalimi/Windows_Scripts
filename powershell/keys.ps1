# Get Directory of files
Function Get-Folder($initialDirectory="")

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

$folderSelection = Get-Folder

# arrays to hold the extracted values
$codeArray = @()
$dateArray = @()

# a variable to hold expired codes
$exCodes =""

# Get all files in the directory
$files = Get-ChildItem -Path $folderSelection -File

# Define regex patterns
$codePattern = "[A-Za-z0-9]{5}-[A-Za-z0-9]{5}-[A-Za-z0-9]{5}"
$datePattern = "\d{1,2} \w{3} \d{4}"

# Loop through each file and append its content to the variable
foreach ($file in $files) {
    $fileContent = Get-Content -Path $file.FullName
    
    # Check if the file content is empty
    if ([string]::IsNullOrWhiteSpace($fileContent)) {
        Write-Output "File $($file.Name) is empty. Skipping."
        continue
    }
    # Extract and store the first code match
    $codeMatch = [regex]::Match($fileContent, $codePattern)
    if ($codeMatch.Success) {
        $codeArray += $codeMatch.Value
    } else {
        $codeArray += 'NULL'
    }

    # Extract and store the first date match
    $dateMatch = [regex]::Match($fileContent, $datePattern)
    if ($dateMatch.Success) {
        $dateArray += $dateMatch.Value
    } else {
        $dateArray += 'NULL'
    }
}

# Get the lengths of the arrays
$codeArrayLength = $codeArray.Length
$dateArrayLength = $dateArray.Length

# Output the results
Write-Output "Number of Codes: $codeArrayLength"
Write-Output "Number of Dates: $dateArrayLength"

for ($i = 0; $i -lt $codeArrayLength; $i++) {
    $code = $codeArray[$i]
    $date = $dateArray[$i]
   
    
    if ($date -ne 'NULL') {
        # Convert the extracted date to DateTime and compare with today
        $extractedDate = [datetime]::ParseExact($date, "dd MMM yyyy", $null)
        $today = Get-Date
        if ($extractedDate -eq $today.Date -or $extractedDate -gt $today.Date) {
            continue
        } elseif ($extractedDate -lt $today.Date) {
            $flag = 0
            for ($j = 0; $j -lt $codeArrayLength; $j++) {
                $code2 = $codeArray[$j]
                if ( $code2 -eq $code){
                    $date2 = $dateArray[$j]
                    if ($date -ne 'NULL') {
                        # Convert the extracted date to DateTime and compare with today
                        $extractedDate2 = [datetime]::ParseExact($date, "dd MMM yyyy", $null)
                        $today = Get-Date
                        if ($extractedDate -eq $today.Date -or $extractedDate -gt $today.Date) {
                            $flag = 1
                            break
                        }
                    }
                }
            }
            if ( $exCodes -eq "" ){
                $exCodes = $exCodes + '"' + "$code" + '"'
            }
            else {
                $exCodes = $exCodes + "," + '"' + "$code" + '"'
                Write-Output $exCodes
            }
        }
    } else {
        Write-Output "No valid date to compare."
    }
}
# Crate or ensure the 'output' folder exists
$outputFolderPath = Join-Path -Path $folderSelection -ChildPath "output"
if (-not (Test-Path $outputFolderPath)) {
    New-Item -ItemType Directory -Path $outputFolderPath | Out-Null
}

# Set the file path and write exp codes
$filePath = Join-Path -Path $outputFolderPath -ChildPath "codes.txt"
Set-Content -Path $filePath -Value $exCodes -Force
Write-Output "Rewritten $filePath with unique codes."