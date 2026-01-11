# ============================================================================
# OMR Models Setup Script for Windows
# This script clones all OMR model repositories and sets up their environments
# ============================================================================

param(
    [string]$BaseDir = "C:\CodesOMR",
    [switch]$SkipClone,
    [switch]$SkipEnv,
    [string]$PythonVersion = "3.10"
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Status { param($msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "[-] $msg" -ForegroundColor Red }

# ============================================================================
# Repository Configuration
# ============================================================================
$Repositories = @(
    @{
        Name = "homr"
        Url = "https://github.com/liebharc/homr.git"
        Branch = "main"
        PythonVersion = "3.11"
        InstallMethod = "poetry"  # Uses Poetry
        Description = "End-to-end OMR using vision transformers"
    },
    @{
        Name = "oemer"
        Url = "https://github.com/meteo-team/oemer.git"
        Branch = "main"
        PythonVersion = "3.10"
        InstallMethod = "setup.py"
        Description = "End-to-end OMR system"
    },
    @{
        Name = "SMT"
        Url = "https://github.com/antoniorv6/SMT.git"
        Branch = "master"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Sheet Music Transformer"
    },
    @{
        Name = "SMT-plusplus"
        Url = "https://github.com/antoniorv6/SMT-plusplus.git"
        Branch = "master"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Sheet Music Transformer++"
    },
    @{
        Name = "legato"
        Url = "https://github.com/guang-yng/legato.git"
        Branch = "main"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Legato OMR model"
    },
    @{
        Name = "Polyphonic-TrOMR"
        Url = "https://github.com/NetEase/Polyphonic-TrOMR.git"
        Branch = "master"
        PythonVersion = "3.9"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Polyphonic Transformer OMR"
    },
    @{
        Name = "tf-end-to-end"
        Url = "https://github.com/OMR-Research/tf-end-to-end.git"
        Branch = "master"
        PythonVersion = "3.8"
        InstallMethod = "pip"
        Packages = @("tensorflow", "numpy", "opencv-python")
        Description = "TensorFlow end-to-end OMR for monophonic scores"
    },
    @{
        Name = "keras-retinanet"
        Url = "https://github.com/fizyr/keras-retinanet.git"
        Branch = "main"
        PythonVersion = "3.8"
        InstallMethod = "setup.py"
        Description = "Keras RetinaNet for object detection"
    },
    @{
        Name = "ObjectDetection-OMR"
        Url = "https://github.com/vgilabert94/ObjectDetection-OMR.git"
        Branch = "master"
        PythonVersion = "3.8"
        InstallMethod = "custom"
        Description = "Object detection for OMR using RetinaNet"
    },
    @{
        Name = "MarimbaBot"
        Url = "https://github.com/UHHRobotics22-23/MarimbaBot.git"
        Branch = "main"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "MarimbaBot robotics and vision"
    }
)

# ============================================================================
# Helper Functions
# ============================================================================

function Test-CommandExists {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-Miniconda {
    Write-Status "Checking for Conda..."
    if (Test-CommandExists "conda") {
        Write-Success "Conda is already installed"
        return $true
    }
    
    Write-Warning "Conda not found. Please install Miniconda or Anaconda first."
    Write-Host "Download from: https://docs.conda.io/en/latest/miniconda.html"
    return $false
}

function New-CondaEnvironment {
    param(
        [string]$EnvName,
        [string]$PythonVersion
    )
    
    Write-Status "Creating conda environment: $EnvName (Python $PythonVersion)"
    
    # Check if environment exists
    $envList = conda env list 2>&1
    if ($envList -match $EnvName) {
        Write-Warning "Environment '$EnvName' already exists, skipping creation"
        return $true
    }
    
    try {
        conda create -n $EnvName python=$PythonVersion -y
        Write-Success "Created environment: $EnvName"
        return $true
    }
    catch {
        Write-Error "Failed to create environment: $EnvName"
        return $false
    }
}

function Install-Dependencies {
    param(
        [hashtable]$Repo,
        [string]$RepoPath
    )
    
    $envName = $Repo.Name
    
    Write-Status "Installing dependencies for $($Repo.Name)..."
    
    switch ($Repo.InstallMethod) {
        "requirements" {
            $reqFile = Join-Path $RepoPath $Repo.RequirementsFile
            if (Test-Path $reqFile) {
                conda run -n $envName pip install -r $reqFile
            }
            else {
                Write-Warning "Requirements file not found: $reqFile"
            }
        }
        "setup.py" {
            Push-Location $RepoPath
            conda run -n $envName pip install -e .
            Pop-Location
        }
        "poetry" {
            Push-Location $RepoPath
            conda run -n $envName pip install poetry
            conda run -n $envName poetry install
            Pop-Location
        }
        "pip" {
            if ($Repo.Packages) {
                $packages = $Repo.Packages -join " "
                conda run -n $envName pip install $packages
            }
        }
        "custom" {
            Write-Warning "Custom installation required for $($Repo.Name). See repository README."
        }
    }
    
    Write-Success "Dependencies installed for $($Repo.Name)"
}

# ============================================================================
# Main Script
# ============================================================================

Write-Host ""
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "       OMR Models Setup Script                          " -ForegroundColor Magenta
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host ""

# Check prerequisites
if (-not (Install-Miniconda)) {
    exit 1
}

if (-not (Test-CommandExists "git")) {
    Write-Error "Git is not installed. Please install Git first."
    exit 1
}

# Create base directory
if (-not (Test-Path $BaseDir)) {
    New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
}

Set-Location $BaseDir

# Process each repository
foreach ($repo in $Repositories) {
    Write-Host ""
    Write-Host "--------------------------------------------------------" -ForegroundColor Blue
    Write-Host "  Setting up: $($repo.Name)" -ForegroundColor Blue
    Write-Host "  $($repo.Description)" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------------" -ForegroundColor Blue
    
    $repoPath = Join-Path $BaseDir $repo.Name
    
    # Clone repository
    if (-not $SkipClone) {
        if (Test-Path $repoPath) {
            Write-Warning "Repository already exists: $($repo.Name)"
            Write-Status "Pulling latest changes..."
            Push-Location $repoPath
            git pull origin $repo.Branch
            Pop-Location
        }
        else {
            Write-Status "Cloning $($repo.Url)..."
            git clone --branch $repo.Branch $repo.Url $repoPath
            Write-Success "Cloned: $($repo.Name)"
        }
    }
    
    # Create environment and install dependencies
    if (-not $SkipEnv) {
        if (New-CondaEnvironment -EnvName $repo.Name -PythonVersion $repo.PythonVersion) {
            Install-Dependencies -Repo $repo -RepoPath $repoPath
        }
    }
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "To activate an environment, use:" -ForegroundColor Yellow
Write-Host "  conda activate <model-name>" -ForegroundColor White
Write-Host ""
Write-Host "Available environments:" -ForegroundColor Yellow
foreach ($repo in $Repositories) {
    Write-Host "  - $($repo.Name)" -ForegroundColor White
}
Write-Host ""
