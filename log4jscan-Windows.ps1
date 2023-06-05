# Proxy credentials
# Uncomment and provide the appropriate proxy credentials if required
# $pass = ConvertTo-SecureString "<Password>" -AsPlainText -Force
# $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "<user>", $pass


# Download Log4jScanner-2.1.3.0.zip file
try {
    # Uncomment the line below and provide proxy details if needed
    # Invoke-WebRequest -Uri "https://github.com/Qualys/log4jscanwin/releases/download/2.1.3.0/Log4jScanner-2.1.3.0.zip" -Proxy http://<ip:port> -ProxyCredential $cred -UseBasicParsing -OutFile $env:TEMP\Log4jScanner-2.1.3.0.zip
    
    # Comment out the line below if using a proxy
    Invoke-WebRequest -Uri "https://github.com/Qualys/log4jscanwin/releases/download/2.1.3.0/Log4jScanner-2.1.3.0.zip" -UseBasicParsing -OutFile $env:TEMP\Log4jScanner-2.1.3.0.zip
} catch {
    Write-Host "Failed to download Log4jScanner-2.1.3.0.zip"
    exit 404
}

# Unzip downloaded file
try {
    Expand-Archive -Path $env:TEMP\Log4jScanner-2.1.3.0.zip -DestinationPath $env:TEMP\
} catch {
    Write-Host "Failed to unzip Log4jScanner-2.1.3.0.zip"
    exit 2
}

$Arch = (Get-Process -Id $PID).StartInfo.EnvironmentVariables["PROCESSOR_ARCHITECTURE"]

if ($Arch -eq 'x86') {
    # Start scan process
    try {
        Set-Location $env:TEMP\Log4jScanner\x86
        .\Log4jScanner.exe /scan /report_sig | Out-Null
    } catch {
        Write-Host "Failed to execute Log4jScanner.exe"
        exit 3
    }
}
elseif ($Arch -eq 'amd64') {
    # Start scan process
    try {
        Set-Location $env:TEMP\Log4jScanner\x64
        .\Log4jScanner.exe /scan /report_sig | Out-Null
    } catch {
        Write-Host "Failed to execute Log4jScanner.exe"
        exit 3
    }
}

# Read log4j_f.out file
try {
    Get-Content -Path C:\ProgramData\Qualys\log4j_findings.out -ErrorAction Stop
} catch {
    if ($_.Exception.GetType().Name -eq "ItemNotFoundException") {
        Write-Host "log4j_findings.out file not found."
    } else {
        Write-Host "Failed to read log4j_findings.out"
    }
    exit 4
}

Write-Host "`n`n"

# Read log4j_s.out file
try {
    Get-Content -Path C:\ProgramData\Qualys\log4j_summary.out -ErrorAction Stop
} catch {
    if ($_.Exception.GetType().Name -eq "ItemNotFoundException") {
        Write-Host "log4j_summary.out file not found."
    } else {
        Write-Host "Failed to read log4j_summary.out"
    }
    exit 4
}

# Clean up files and folders
Remove-Item -Path $env:TEMP\Log4jScanner-2.1.3.0.zip -Force -ErrorAction SilentlyContinue
Set-Location $env:TEMP
Remove-Item -Path $env:TEMP\Log4jScanner -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path C:\ProgramData\Qualys\log4j_findings.out -Force -ErrorAction SilentlyContinue
Remove-Item -Path C:\ProgramData\Qualys\log4j_summary.out -Force -ErrorAction SilentlyContinue