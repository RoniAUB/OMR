# OMR Models Collection - Automated Setup

[![Setup OMR Models](https://github.com/YOUR_USERNAME/OMR/actions/workflows/setup-omr-models.yml/badge.svg)](https://github.com/YOUR_USERNAME/OMR/actions/workflows/setup-omr-models.yml)

Automated scripts to clone and configure all major **Optical Music Recognition (OMR)** models from their original GitHub repositories. This eliminates the need to store large model files - instead, everything is cloned fresh from the source.

## 🎵 Included Models

| Model | Description | Original Repository | Python |
|-------|-------------|---------------------|--------|
| **homr** | End-to-end OMR using vision transformers | [liebharc/homr](https://github.com/liebharc/homr) | 3.11 |
| **oemer** | End-to-end OMR system | [meteo-team/oemer](https://github.com/meteo-team/oemer) | 3.10 |
| **SMT** | Sheet Music Transformer | [antoniorv6/SMT](https://github.com/antoniorv6/SMT) | 3.10 |
| **SMT-plusplus** | Sheet Music Transformer++ | [antoniorv6/SMT-plusplus](https://github.com/antoniorv6/SMT-plusplus) | 3.10 |
| **legato** | Legato OMR model | [guang-yng/legato](https://github.com/guang-yng/legato) | 3.10 |
| **Polyphonic-TrOMR** | Polyphonic Transformer OMR | [NetEase/Polyphonic-TrOMR](https://github.com/NetEase/Polyphonic-TrOMR) | 3.9 |
| **tf-end-to-end** | TensorFlow CTC-based OMR | [OMR-Research/tf-end-to-end](https://github.com/OMR-Research/tf-end-to-end) | 3.8 |
| **keras-retinanet** | RetinaNet object detection | [fizyr/keras-retinanet](https://github.com/fizyr/keras-retinanet) | 3.8 |
| **ObjectDetection-OMR** | Object detection for OMR | [vgilabert94/ObjectDetection-OMR](https://github.com/vgilabert94/ObjectDetection-OMR) | 3.8 |
| **MarimbaBot** | Robotics and music vision | [UHHRobotics22-23/MarimbaBot](https://github.com/UHHRobotics22-23/MarimbaBot) | 3.10 |

---

## 📋 Prerequisites

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

## 🚀 Installation & Usage

### 📘 Windows

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

### 🐧 Linux

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/OMR.git
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

### 🍎 macOS

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/OMR.git
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

## 📁 Directory Structure After Setup

```
CodesOMR/                       # or your custom directory
├── homr/                       # liebharc/homr
├── oemer/                      # meteo-team/oemer
├── SMT/                        # antoniorv6/SMT
├── SMT-plusplus/               # antoniorv6/SMT-plusplus
├── legato/                     # guang-yng/legato
├── Polyphonic-TrOMR/           # NetEase/Polyphonic-TrOMR
├── tf-end-to-end/              # OMR-Research/tf-end-to-end
├── keras-retinanet/            # fizyr/keras-retinanet
├── ObjectDetection-OMR/        # vgilabert94/ObjectDetection-OMR
└── MarimbaBot/                 # UHHRobotics22-23/MarimbaBot
```

---

## 🔧 Using the Models

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
python -m homr <input_image.png>
```

#### oemer
```bash
conda activate oemer
python main.py -i <input_image.png>
```

#### SMT / SMT-plusplus
```bash
conda activate SMT
python predict.py --image <input_image.png>
```

#### legato
```bash
conda activate legato
python run_legato_inference.py --image <input_image.png>
```

---

## ⚠️ Troubleshooting

### Common Issues

<details>
<summary><b>❌ Conda not found</b></summary>

**Solution:**
1. Ensure Miniconda/Anaconda is installed
2. Add conda to your PATH:
   - **Windows:** Restart terminal or run `conda init powershell`
   - **Linux/macOS:** Run `conda init bash` or `conda init zsh`
3. Restart your terminal

</details>

<details>
<summary><b>❌ Git clone fails</b></summary>

**Solution:**
1. Check your internet connection
2. Verify Git is installed: `git --version`
3. Try cloning manually: `git clone <repo_url>`
4. If behind a firewall, configure Git proxy settings

</details>

<details>
<summary><b>❌ Package installation fails</b></summary>

**Solution:**
1. Some packages require specific Python versions (handled automatically)
2. GPU packages may need CUDA installed
3. Try installing packages manually:
   ```bash
   conda activate <model-name>
   pip install -r requirements.txt
   ```

</details>

<details>
<summary><b>❌ Poetry installation fails (homr)</b></summary>

**Solution:**
```bash
conda activate homr
pip install poetry
cd homr
poetry install --no-interaction
```

</details>

<details>
<summary><b>❌ CUDA/GPU issues</b></summary>

**Solution:**
1. Update NVIDIA drivers
2. Install CUDA Toolkit matching your PyTorch version
3. For CPU-only usage, install CPU versions:
   ```bash
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
   ```

</details>

<details>
<summary><b>❌ Permission denied (Linux/macOS)</b></summary>

**Solution:**
```bash
chmod +x setup_all_omr_models.sh
```

</details>

---

## 🔄 Updating Models

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

- ✅ Each model has its own isolated conda environment (no dependency conflicts)
- ✅ Model weights are downloaded from original repositories or Hugging Face
- ✅ Scripts are idempotent - safe to run multiple times
- ⚠️ Some models may require additional setup (datasets, weights, etc.)
- 📖 Check each model's README for specific usage instructions

---

## 🔗 Original Repositories

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

---

## 📄 License

This setup script repository is provided under the MIT License.

Each OMR model retains its original license. Please refer to the LICENSE file in each repository for details.

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report issues
- Suggest new models to include
- Improve the setup scripts
- Add documentation

---

## ⭐ Star this repo if you find it useful!
