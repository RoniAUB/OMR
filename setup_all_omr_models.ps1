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
        InstallMethod = "poetry"
        Description = "End-to-end OMR using vision transformers"
        PostInstall = $null
    },
    @{
        Name = "oemer"
        Url = "https://github.com/meteo-team/oemer.git"
        Branch = "main"
        PythonVersion = "3.10"
        InstallMethod = "setup.py"
        Description = "End-to-end OMR system"
        PostInstall = $null
    },
    @{
        Name = "SMT"
        Url = "https://github.com/antoniorv6/SMT.git"
        Branch = "master"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Sheet Music Transformer"
        PostInstall = $null
    },
    @{
        Name = "SMT-plusplus"
        Url = "https://github.com/antoniorv6/SMT-plusplus.git"
        Branch = "master"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Sheet Music Transformer++ (deprecated, merged into SMT)"
        PostInstall = $null
    },
    @{
        Name = "legato"
        Url = "https://github.com/guang-yng/legato.git"
        Branch = "main"
        PythonVersion = "3.12"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "LEGATO: Large-Scale End-to-end OMR (requires HuggingFace token!)"
        PostInstall = "huggingface_hub"
        SpecialNote = @"
    
    ========================================================
    IMPORTANT: Legato requires HuggingFace authentication!
    ========================================================
    After setup, run these commands:
      conda activate legato
      huggingface-cli login
    
    Then paste your HuggingFace token.
    Get a token at: https://huggingface.co/settings/tokens
    ========================================================
"@
    },
    @{
        Name = "Polyphonic-TrOMR"
        Url = "https://github.com/NetEase/Polyphonic-TrOMR.git"
        Branch = "master"
        PythonVersion = "3.9"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "Polyphonic Transformer OMR"
        PostInstall = $null
    },
    @{
        Name = "tf-end-to-end"
        Url = "https://github.com/OMR-Research/tf-end-to-end.git"
        Branch = "master"
        PythonVersion = "3.8"
        InstallMethod = "pip"
        Packages = @("tensorflow", "numpy", "opencv-python")
        Description = "TensorFlow end-to-end OMR for monophonic scores"
        PostInstall = $null
    },
    @{
        Name = "keras-retinanet"
        Url = "https://github.com/fizyr/keras-retinanet.git"
        Branch = "main"
        PythonVersion = "3.8"
        InstallMethod = "setup.py"
        Description = "Keras RetinaNet for object detection"
        PostInstall = $null
    },
    @{
        Name = "ObjectDetection-OMR"
        Url = "https://github.com/vgilabert94/ObjectDetection-OMR.git"
        Branch = "master"
        PythonVersion = "3.8"
        InstallMethod = "custom"
        Description = "Object detection for OMR using RetinaNet"
        PostInstall = $null
    },
    @{
        Name = "MarimbaBot"
        Url = "https://github.com/UHHRobotics22-23/MarimbaBot.git"
        Branch = "main"
        PythonVersion = "3.10"
        InstallMethod = "requirements"
        RequirementsFile = "requirements.txt"
        Description = "MarimbaBot robotics and vision"
        PostInstall = $null
    },
    @{
        Name = "OpenOMR"
        Url = "https://github.com/anyati/OpenOMR.git"
        Branch = "master"
        PythonVersion = $null  # Java-based
        InstallMethod = "java"
        Description = "Java-based OMR using neural networks"
        PostInstall = $null
        SpecialNote = @"
    
    ========================================================
    NOTE: OpenOMR is a Java application!
    ========================================================
    Requires: Java JDK 8+, Joone, JFreeChart, JCommon
    See the repository README for Java setup instructions.
    ========================================================
"@
    },
    @{
        Name = "cadenCV"
        Url = "https://github.com/anyati/cadenCV.git"
        Branch = "master"
        PythonVersion = "3.9"
        InstallMethod = "pip"
        Packages = @("numpy", "matplotlib", "opencv-python", "MIDIUtil")
        Description = "Python OMR system with MIDI output"
        PostInstall = $null
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
            # Install post-install packages (e.g., huggingface_hub for legato)
            if ($Repo.PostInstall) {
                conda run -n $envName pip install $Repo.PostInstall
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
            conda run -n $envName poetry install --no-interaction
            Pop-Location
        }
        "pip" {
            if ($Repo.Packages) {
                $packages = $Repo.Packages -join " "
                conda run -n $envName pip install $packages
            }
        }
        "java" {
            Write-Warning "Java-based project. Skipping Python environment setup."
            Write-Host "Please install Java JDK and required libraries manually." -ForegroundColor Yellow
        }
        "custom" {
            Write-Warning "Custom installation required for $($Repo.Name). See repository README."
        }
    }
    
    # Display special notes if any
    if ($Repo.SpecialNote) {
        Write-Host $Repo.SpecialNote -ForegroundColor Yellow
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
        # Skip conda environment for Java-based projects
        if ($repo.InstallMethod -eq "java") {
            Write-Warning "Skipping conda environment for Java-based project: $($repo.Name)"
            if ($repo.SpecialNote) {
                Write-Host $repo.SpecialNote -ForegroundColor Yellow
            }
        }
        elseif ($repo.PythonVersion) {
            if (New-CondaEnvironment -EnvName $repo.Name -PythonVersion $repo.PythonVersion) {
                Install-Dependencies -Repo $repo -RepoPath $repoPath
            }
        }
    }
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Legato requires HuggingFace authentication:" -ForegroundColor Yellow
Write-Host "   conda activate legato" -ForegroundColor White
Write-Host "   huggingface-cli login" -ForegroundColor White
Write-Host "   (Get token at: https://huggingface.co/settings/tokens)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "2. OpenOMR is a Java application - see its README for setup" -ForegroundColor Yellow
Write-Host ""
Write-Host "To activate an environment, use:" -ForegroundColor Cyan
Write-Host "  conda activate <model-name>" -ForegroundColor White
Write-Host ""
Write-Host "Available environments:" -ForegroundColor Cyan
foreach ($repo in $Repositories) {
    if ($repo.PythonVersion) {
        Write-Host "  - $($repo.Name) (Python $($repo.PythonVersion))" -ForegroundColor White
    } else {
        Write-Host "  - $($repo.Name) (Java)" -ForegroundColor DarkGray
    }
}
}
Write-Host ""
