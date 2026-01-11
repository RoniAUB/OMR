# ============================================================================
# OMR Models Inference Runner - PowerShell Wrapper
# Run all OMR models on the same input image
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Input,
    
    [Parameter(Mandatory=$false)]
    [string]$Output = ".\omr_results",
    
    [Parameter(Mandatory=$false)]
    [string]$Models,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("cpu", "cuda")]
    [string]$Device = "cpu",
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 300,
    
    [Parameter(Mandatory=$false)]
    [switch]$ListModels,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir

function Show-Help {
    Write-Host ""
    Write-Host "OMR Models Inference Runner" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\run_inference.ps1 -Input <image> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Input       Path to input image (required)"
    Write-Host "  -Output      Output directory (default: .\omr_results)"
    Write-Host "  -Models      Comma-separated list of models to run"
    Write-Host "  -Device      Device: cpu or cuda (default: cpu)"
    Write-Host "  -Timeout     Timeout per model in seconds (default: 300)"
    Write-Host "  -ListModels  List all available models"
    Write-Host "  -Help        Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\run_inference.ps1 -Input score.png"
    Write-Host "  .\run_inference.ps1 -Input score.png -Models homr,oemer,legato"
    Write-Host "  .\run_inference.ps1 -Input score.png -Device cuda -Output .\results"
    Write-Host ""
}

# Show help
if ($Help) {
    Show-Help
    exit 0
}

# List models
if ($ListModels) {
    python "$ScriptDir\run_all_inference.py" --list-models
    exit 0
}

# Check input
if (-not $Input) {
    Write-Host "Error: -Input is required" -ForegroundColor Red
    Show-Help
    exit 1
}

if (-not (Test-Path $Input)) {
    Write-Host "Error: Input file not found: $Input" -ForegroundColor Red
    exit 1
}

# Build command arguments
$args = @(
    "$ScriptDir\run_all_inference.py",
    "--input", $Input,
    "--output", $Output,
    "--device", $Device,
    "--timeout", $Timeout,
    "--base-dir", $BaseDir
)

if ($Models) {
    $args += "--models"
    $args += $Models
}

# Run
Write-Host "Running OMR inference..." -ForegroundColor Cyan
python @args
