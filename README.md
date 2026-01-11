# OMR Models Automated Setup

[![Setup OMR Models](https://github.com/RoniAUB/OMR/actions/workflows/setup-omr-models.yml/badge.svg)](https://github.com/RoniAUB/OMR/actions/workflows/setup-omr-models.yml)

Automated scripts to clone and configure all major **Optical Music Recognition (OMR)** models from their original GitHub repositories. This eliminates the need to store large model files - instead, everything is cloned fresh from the source.

## Included Models

| Model | Description | Original Repository | Python |
|-------|-------------|---------------------|--------|
| **homr** | End-to-end OMR using vision transformers | [liebharc/homr](https://github.com/liebharc/homr) | 3.11 |
| **oemer** | End-to-end OMR system | [meteo-team/oemer](https://github.com/meteo-team/oemer) | 3.10 |
| **SMT** | Sheet Music Transformer | [antoniorv6/SMT](https://github.com/antoniorv6/SMT) | 3.10 |
| **SMT-plusplus** | Sheet Music Transformer++ (deprecated, merged into SMT) | [antoniorv6/SMT-plusplus](https://github.com/antoniorv6/SMT-plusplus) | 3.10 |
| **legato** | Large-scale End-to-end OMR | [guang-yng/legato](https://github.com/guang-yng/legato) | 3.12 |
| **Polyphonic-TrOMR** | Polyphonic Transformer OMR | [NetEase/Polyphonic-TrOMR](https://github.com/NetEase/Polyphonic-TrOMR) | 3.9 |
| **tf-end-to-end** | TensorFlow CTC-based OMR (monophonic) | [OMR-Research/tf-end-to-end](https://github.com/OMR-Research/tf-end-to-end) | 3.8 |
| **keras-retinanet** | RetinaNet object detection | [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet) | 3.8 |
| **ObjectDetection-OMR** | Object detection for OMR using RetinaNet | [vgilabert94/ObjectDetection-OMR](https://github.com/vgilabert94/ObjectDetection-OMR) | 3.8 |
| **MarimbaBot** | Robotics and music vision | [UHHRobotics22-23/MarimbaBot](https://github.com/UHHRobotics22-23/MarimbaBot) | 3.10 |
| **OpenOMR** | Java-based OMR using neural networks | [anyati/OpenOMR](https://github.com/anyati/OpenOMR) | Java |
| **cadenCV** | Python OMR system with MIDI output | [anyati/cadenCV](https://github.com/anyati/cadenCV) | 3.6 |

---

## Prerequisites

Before running the setup scripts, ensure you have the following installed:

### Required Software

| Software | Download Link | Purpose |
|----------|---------------|---------|
| **Git** | [git-scm.com](https://git-scm.com/downloads) | Clone repositories |
| **Conda** | [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/download) | Manage Python environments |

### Optional (for GPU Support)
- NVIDIA GPU with CUDA support
- [CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
- [cuDNN](https://developer.nvidia.com/cudnn)

---

## Installation & Usage

### Windows

#### Option 1: Double-click (Easiest)
1. Download or clone this repository
2. Double-click `setup_all_omr_models.bat`
3. Wait for all models to be cloned and configured

#### Option 2: PowerShell
```powershell
# Clone this repository
git clone https://github.com/YOUR_USERNAME/OMR.git
cd OMR

# Allow script execution (run once, requires admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the setup script
.\setup_all_omr_models.ps1
```

#### PowerShell Options
```powershell
# Specify a custom installation directory
.\setup_all_omr_models.ps1 -BaseDir "D:\MyOMRModels"

# Skip cloning (if repositories already exist)
.\setup_all_omr_models.ps1 -SkipClone

# Skip environment creation (clone only)
.\setup_all_omr_models.ps1 -SkipEnv
```

---

### Linux

```bash
# Clone this repository
git clone https://github.com/RoniAUB/OMR.git
cd OMR

# Make the script executable
chmod +x setup_all_omr_models.sh

# Run the setup script
./setup_all_omr_models.sh
```

#### Linux Options
```bash
# Specify a custom installation directory
./setup_all_omr_models.sh --base-dir ~/my_omr_models

# Skip cloning (if repositories already exist)
./setup_all_omr_models.sh --skip-clone

# Skip environment creation (clone only)
./setup_all_omr_models.sh --skip-env
```

---

### macOS

```bash
# Clone this repository
git clone https://github.com/RoniAUB/OMR.git
cd OMR

# Make the script executable
chmod +x setup_all_omr_models.sh

# Run the setup script
./setup_all_omr_models.sh
```

#### macOS Options
```bash
# Specify a custom installation directory
./setup_all_omr_models.sh --base-dir ~/my_omr_models

# Skip cloning (if repositories already exist)
./setup_all_omr_models.sh --skip-clone

# Skip environment creation (clone only)
./setup_all_omr_models.sh --skip-env
```

> **Note for macOS:** Some models may require additional dependencies. Install Xcode Command Line Tools if prompted:
> ```bash
> xcode-select --install
> ```

---

## Directory Structure After Setup

```
CodesOMR/                       # or your custom directory
├── homr/                       # liebharc/homr
├── oemer/                      # meteo-team/oemer
├── SMT/                        # antoniorv6/SMT
├── SMT-plusplus/               # antoniorv6/SMT-plusplus
├── legato/                     # guang-yng/legato
├── Polyphonic-TrOMR/           # NetEase/Polyphonic-TrOMR
├── OpenOMR/                    # anyati/OpenOMR (Java)
├── cadenCV/                    # anyati/cadenCV
├── tf-end-to-end/              # OMR-Research/tf-end-to-end
├── keras-retinanet/            # fizyr/keras-retinanet
├── ObjectDetection-OMR/        # vgilabert94/ObjectDetection-OMR
└── MarimbaBot/                 # UHHRobotics22-23/MarimbaBot
```

---

## Special Setup Requirements

### Legato - HuggingFace Token Required

Legato uses models hosted on HuggingFace that require authentication. **You must complete these steps before running inference:**

#### Step 1: Create a HuggingFace Account
1. Go to [huggingface.co](https://huggingface.co) and create an account
2. Verify your email address

#### Step 2: Create an Access Token
1. Go to [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
2. Click **"New token"**
3. Name it (e.g., "legato-access")
4. Select **"Read"** access
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

#### Step 3: Authenticate with HuggingFace CLI
```bash
conda activate legato
pip install huggingface_hub
huggingface-cli login
# Paste your token when prompted
```

#### Step 4: Accept Model License (if required)
Visit the model pages and accept any license agreements:
- [guangyangmusic/legato](https://huggingface.co/guangyangmusic/legato)
- [guangyangmusic/legato-small](https://huggingface.co/guangyangmusic/legato-small)

#### Step 5: Run Inference
```bash
conda activate legato
PYTHONPATH=. python scripts/inference.py \
    --model_path guangyangmusic/legato \
    --image_path path/to/image.png
```

> ⚠️ **Note:** Legato requires Python 3.12 and was tested with CUDA 12.4

---

### OpenOMR - Java Setup Required

OpenOMR is a Java-based application and requires:
1. Java JDK 8 or higher
2. Additional libraries: Joone, JFreeChart, JCommon

```bash
# Install Java (if not installed)
# Windows: Download from https://adoptium.net/
# Linux: sudo apt install openjdk-11-jdk
# macOS: brew install openjdk@11

# Run OpenOMR (after downloading dependencies)
java -classpath "joone-engine.jar:jcommon-1.0.5.jar:jfreechart-1.0.1.jar:." \
     -Xmx256m openomr.openomr.SheetMusic
```

---

### cadenCV - Simple Python OMR

cadenCV is a simpler OMR system that outputs MIDI files.

```bash
conda activate cadenCV
pip install numpy matplotlib opencv-python MIDIUtil
python main.py "path/to/sheet_music.png"
```

---

## Running All Models (Inference Comparison)

After setup, you can run **all models on the same input image** to compare their outputs!

### Windows (PowerShell)

```powershell
# Run all models on an image
.\run_inference.ps1 -Input "path\to\score.png"

# Run specific models only
.\run_inference.ps1 -Input "score.png" -Models "homr,oemer,legato"

# Use GPU acceleration
.\run_inference.ps1 -Input "score.png" -Device cuda

# Custom output directory
.\run_inference.ps1 -Input "score.png" -Output ".\my_results"

# List available models
.\run_inference.ps1 -ListModels
```

### Linux / macOS

```bash
# Make executable (first time only)
chmod +x run_inference.sh

# Run all models on an image
./run_inference.sh --input path/to/score.png

# Run specific models only
./run_inference.sh --input score.png --models homr,oemer,legato

# Use GPU acceleration
./run_inference.sh --input score.png --device cuda

# List available models
./run_inference.sh --list
```

### Python (Direct)

```bash
# Run all models
python run_all_inference.py --input score.png --output ./results

# Run specific models
python run_all_inference.py --input score.png --models homr,oemer,legato,Polyphonic-TrOMR

# With GPU
python run_all_inference.py --input score.png --device cuda

# List models
python run_all_inference.py --list-models
```

### Output Structure

After running inference, results are saved in the output directory:

```
omr_results/
├── inference_results.json    # Summary of all results
├── homr/
│   └── score.musicxml        # homr output
├── oemer/
│   └── score.musicxml        # oemer output
├── legato/
│   └── score_output.txt      # ABC notation output
├── Polyphonic-TrOMR/
│   └── score_output.txt      # TrOMR output
└── ...
```

---

## Using Individual Models

After setup, activate the environment for the model you want to use:

```bash
# Activate an environment
conda activate <model-name>

# Examples:
conda activate homr
conda activate SMT
conda activate legato
conda activate oemer
```

### Quick Usage Examples

#### homr
```bash
conda activate homr
poetry run homr <input_image.png>
# Output: MusicXML file in the same directory
```

#### oemer
```bash
conda activate oemer
oemer <input_image.png>
# Or: python main.py -i <input_image.png>
# Output: MusicXML file and analyzed image
```

#### SMT
```bash
conda activate SMT
python predict.py --image <input_image.png>
```

#### Polyphonic-TrOMR
```bash
conda activate Polyphonic-TrOMR
python ./tromr/inference.py <input_image.png>
```

#### legato (after HuggingFace setup)
```bash
conda activate legato
PYTHONPATH=. python scripts/inference.py \
    --model_path guangyangmusic/legato \
    --image_path <input_image.png>
```

---

##  Updating Models

To update all models to their latest versions:

```bash
# Re-run the setup script (it will pull latest changes)
./setup_all_omr_models.sh      # Linux/macOS
.\setup_all_omr_models.ps1     # Windows
```

Or update manually:
```bash
cd <model-directory>
git pull origin main  # or master, depending on the repo
```

---

## 📝 Notes

- Each model has its own isolated conda environment (no dependency conflicts)
- Model weights are downloaded from original repositories or Hugging Face
- Scripts are idempotent - safe to run multiple times
- Some models may require additional setup (datasets, weights, etc.)
- Check each model's README for specific usage instructions

---

## Original Repositories

| Model | Repository |
|-------|------------|
| homr | https://github.com/liebharc/homr |
| oemer | https://github.com/meteo-team/oemer |
| SMT | https://github.com/antoniorv6/SMT |
| SMT-plusplus | https://github.com/antoniorv6/SMT-plusplus |
| legato | https://github.com/guang-yng/legato |
| Polyphonic-TrOMR | https://github.com/NetEase/Polyphonic-TrOMR |
| tf-end-to-end | https://github.com/OMR-Research/tf-end-to-end |
| keras-retinanet | https://github.com/fizyr/keras-retinanet |
| ObjectDetection-OMR | https://github.com/vgilabert94/ObjectDetection-OMR |
| MarimbaBot | https://github.com/UHHRobotics22-23/MarimbaBot |
| OpenOMR | https://github.com/anyati/OpenOMR |
| cadenCV | https://github.com/anyati/cadenCV |

---


## ⭐ Star this repo if you find it useful!
