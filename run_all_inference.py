#!/usr/bin/env python3
"""
OMR Models Inference Runner
===========================
Run all available OMR models on the same input image and collect results.

Usage:
    python run_all_inference.py --input <image_path> --output <output_dir>
    python run_all_inference.py --input image.png --output ./results --models homr,oemer,SMT

Author: RoniAUB
Repository: https://github.com/RoniAUB/OMR
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# ============================================================================
# Configuration
# ============================================================================

MODELS_CONFIG = {
    "homr": {
        "name": "homr",
        "description": "End-to-end OMR using vision transformers",
        "python_version": "3.11",
        "command_type": "poetry",
        "command": "poetry run homr {input}",
        "working_dir": "homr",
        "output_format": "musicxml",
        "output_pattern": "{input_stem}.musicxml",
        "conda_env": "homr",
    },
    "oemer": {
        "name": "oemer",
        "description": "End-to-end OMR system",
        "python_version": "3.10",
        "command_type": "module",
        "command": "oemer {input} -o {output_dir}",
        "working_dir": "oemer",
        "output_format": "musicxml",
        "output_pattern": "{input_stem}.musicxml",
        "conda_env": "oemer",
    },
    "SMT": {
        "name": "SMT",
        "description": "Sheet Music Transformer",
        "python_version": "3.10",
        "command_type": "python",
        "command": "python predict.py --image {input}",
        "working_dir": "SMT",
        "output_format": "bekern",
        "output_pattern": None,  # Outputs to stdout
        "conda_env": "SMT",
        "huggingface_model": "PRAIG/smt-grandstaff",
    },
    "SMT-plusplus": {
        "name": "SMT-plusplus",
        "description": "Sheet Music Transformer++ (deprecated)",
        "python_version": "3.10",
        "command_type": "python",
        "command": "python predict.py --image {input}",
        "working_dir": "SMT-plusplus",
        "output_format": "bekern",
        "output_pattern": None,
        "conda_env": "SMT-plusplus",
        "deprecated": True,
    },
    "legato": {
        "name": "legato",
        "description": "LEGATO: Large-scale End-to-end OMR",
        "python_version": "3.12",
        "command_type": "python",
        "command": "python scripts/inference.py --model_path guangyangmusic/legato --image_path {input} --device {device}",
        "working_dir": "legato",
        "output_format": "abc",
        "output_pattern": None,  # Outputs to stdout
        "conda_env": "legato",
        "requires_hf_auth": True,
        "env_vars": {"PYTHONPATH": "."},
    },
    "Polyphonic-TrOMR": {
        "name": "Polyphonic-TrOMR",
        "description": "Polyphonic Transformer OMR",
        "python_version": "3.9",
        "command_type": "python",
        "command": "python tromr/inference.py {input}",
        "working_dir": "Polyphonic-TrOMR",
        "output_format": "custom",
        "output_pattern": None,
        "conda_env": "Polyphonic-TrOMR",
    },
    "tf-end-to-end": {
        "name": "tf-end-to-end",
        "description": "TensorFlow CTC-based OMR (monophonic)",
        "python_version": "3.8",
        "command_type": "python",
        "command": "python ctc_predict.py -image {input} -model {model} -vocabulary {vocabulary}",
        "working_dir": "tf-end-to-end",
        "output_format": "semantic",
        "output_pattern": None,
        "conda_env": "tf-end-to-end",
        "requires_model": True,
        "model_note": "Requires trained model. Download from PrIMuS dataset.",
    },
    "cadenCV": {
        "name": "cadenCV",
        "description": "Python OMR with MIDI output",
        "python_version": "3.9",
        "command_type": "python",
        "command": "python main.py {input}",
        "working_dir": "cadenCV",
        "output_format": "midi",
        "output_pattern": "output/*.mid",
        "conda_env": "cadenCV",
    },
}

# Models that are ready to run without additional setup
READY_MODELS = ["homr", "oemer", "legato", "Polyphonic-TrOMR", "cadenCV"]

# ============================================================================
# Utility Functions
# ============================================================================

def get_conda_run_command(env_name: str, command: str, working_dir: str = None) -> List[str]:
    """Build conda run command."""
    cmd = ["conda", "run", "-n", env_name, "--no-capture-output"]
    if working_dir:
        cmd.extend(["--cwd", working_dir])
    cmd.extend(command.split())
    return cmd


def run_command(
    command: List[str],
    working_dir: str = None,
    env_vars: Dict[str, str] = None,
    timeout: int = 300,
    capture_output: bool = True
) -> Tuple[int, str, str]:
    """Run a command and return exit code, stdout, stderr."""
    env = os.environ.copy()
    if env_vars:
        env.update(env_vars)
    
    try:
        result = subprocess.run(
            command,
            cwd=working_dir,
            env=env,
            capture_output=capture_output,
            text=True,
            timeout=timeout
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Command timed out after {timeout} seconds"
    except Exception as e:
        return -1, "", str(e)


def check_conda_env_exists(env_name: str) -> bool:
    """Check if a conda environment exists."""
    code, stdout, _ = run_command(["conda", "env", "list"])
    return env_name in stdout


def find_output_file(output_dir: str, pattern: str, input_stem: str) -> Optional[str]:
    """Find output file based on pattern."""
    if pattern is None:
        return None
    
    pattern = pattern.format(input_stem=input_stem)
    output_path = Path(output_dir)
    
    if "*" in pattern:
        # Glob pattern
        matches = list(output_path.glob(pattern))
        return str(matches[0]) if matches else None
    else:
        # Direct path
        full_path = output_path / pattern
        return str(full_path) if full_path.exists() else None


class Colors:
    """ANSI color codes for terminal output."""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def print_status(msg: str, color: str = Colors.CYAN):
    """Print status message with color."""
    print(f"{color}[*] {msg}{Colors.ENDC}")


def print_success(msg: str):
    """Print success message."""
    print(f"{Colors.GREEN}[+] {msg}{Colors.ENDC}")


def print_warning(msg: str):
    """Print warning message."""
    print(f"{Colors.YELLOW}[!] {msg}{Colors.ENDC}")


def print_error(msg: str):
    """Print error message."""
    print(f"{Colors.RED}[-] {msg}{Colors.ENDC}")


# ============================================================================
# Model Runners
# ============================================================================

class OMRModelRunner:
    """Run an OMR model on an input image."""
    
    def __init__(self, base_dir: str, output_dir: str, device: str = "cpu"):
        self.base_dir = Path(base_dir)
        self.output_dir = Path(output_dir)
        self.device = device
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def run_model(self, model_name: str, input_image: str, timeout: int = 300) -> Dict:
        """Run a specific model and return results."""
        if model_name not in MODELS_CONFIG:
            return {
                "model": model_name,
                "success": False,
                "error": f"Unknown model: {model_name}",
                "output": None,
                "duration": 0,
            }
        
        config = MODELS_CONFIG[model_name]
        model_output_dir = self.output_dir / model_name
        model_output_dir.mkdir(parents=True, exist_ok=True)
        
        # Check if conda environment exists
        if not check_conda_env_exists(config["conda_env"]):
            return {
                "model": model_name,
                "success": False,
                "error": f"Conda environment '{config['conda_env']}' not found. Run setup script first.",
                "output": None,
                "duration": 0,
            }
        
        # Check if model requires additional setup
        if config.get("requires_model"):
            return {
                "model": model_name,
                "success": False,
                "error": config.get("model_note", "Model requires additional setup"),
                "output": None,
                "duration": 0,
                "skipped": True,
            }
        
        # Build command
        input_path = Path(input_image).absolute()
        input_stem = input_path.stem
        working_dir = str(self.base_dir / config["working_dir"])
        
        # Format command with placeholders
        command = config["command"].format(
            input=str(input_path),
            output_dir=str(model_output_dir),
            device=self.device,
            model="",  # Placeholder for models that need specific model path
            vocabulary="",
        )
        
        # Build full conda command
        env_vars = config.get("env_vars", {})
        
        # Use shell for complex commands
        if config["command_type"] == "poetry":
            full_command = f"cd {working_dir} && conda run -n {config['conda_env']} {command}"
            shell = True
        else:
            full_command = f"cd {working_dir} && conda run -n {config['conda_env']} {command}"
            shell = True
        
        print_status(f"Running {model_name}...")
        print(f"    Command: {command}")
        
        start_time = time.time()
        
        try:
            # Prepare environment
            env = os.environ.copy()
            env.update(env_vars)
            
            result = subprocess.run(
                full_command,
                shell=shell,
                capture_output=True,
                text=True,
                timeout=timeout,
                env=env,
                cwd=working_dir,
            )
            
            duration = time.time() - start_time
            
            if result.returncode == 0:
                # Try to find output file
                output_file = find_output_file(
                    str(model_output_dir), 
                    config.get("output_pattern"), 
                    input_stem
                )
                
                # Copy output to model directory if it was created elsewhere
                if output_file is None and config.get("output_pattern"):
                    # Check in working directory
                    alt_output = find_output_file(
                        working_dir,
                        config.get("output_pattern"),
                        input_stem
                    )
                    if alt_output:
                        dest = model_output_dir / Path(alt_output).name
                        shutil.copy2(alt_output, dest)
                        output_file = str(dest)
                
                # Save stdout as output if no file
                if output_file is None and result.stdout.strip():
                    output_file = str(model_output_dir / f"{input_stem}_output.txt")
                    with open(output_file, "w") as f:
                        f.write(result.stdout)
                
                print_success(f"{model_name} completed in {duration:.2f}s")
                
                return {
                    "model": model_name,
                    "success": True,
                    "output": output_file,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                    "duration": duration,
                    "format": config["output_format"],
                }
            else:
                print_error(f"{model_name} failed")
                return {
                    "model": model_name,
                    "success": False,
                    "error": result.stderr or "Unknown error",
                    "stdout": result.stdout,
                    "duration": duration,
                }
                
        except subprocess.TimeoutExpired:
            duration = time.time() - start_time
            print_error(f"{model_name} timed out after {timeout}s")
            return {
                "model": model_name,
                "success": False,
                "error": f"Timeout after {timeout} seconds",
                "duration": duration,
            }
        except Exception as e:
            duration = time.time() - start_time
            print_error(f"{model_name} error: {e}")
            return {
                "model": model_name,
                "success": False,
                "error": str(e),
                "duration": duration,
            }
    
    def run_all(
        self, 
        input_image: str, 
        models: List[str] = None,
        timeout: int = 300
    ) -> Dict:
        """Run all specified models and return combined results."""
        if models is None:
            models = list(MODELS_CONFIG.keys())
        
        results = {
            "input_image": str(input_image),
            "timestamp": datetime.now().isoformat(),
            "device": self.device,
            "models": {},
            "summary": {
                "total": len(models),
                "successful": 0,
                "failed": 0,
                "skipped": 0,
            }
        }
        
        print()
        print(f"{Colors.HEADER}{'='*60}{Colors.ENDC}")
        print(f"{Colors.HEADER}  OMR Models Inference Runner{Colors.ENDC}")
        print(f"{Colors.HEADER}{'='*60}{Colors.ENDC}")
        print(f"  Input: {input_image}")
        print(f"  Output: {self.output_dir}")
        print(f"  Models: {', '.join(models)}")
        print(f"  Device: {self.device}")
        print(f"{Colors.HEADER}{'='*60}{Colors.ENDC}")
        print()
        
        for model_name in models:
            print(f"\n{Colors.BLUE}{'─'*50}{Colors.ENDC}")
            result = self.run_model(model_name, input_image, timeout)
            results["models"][model_name] = result
            
            if result.get("skipped"):
                results["summary"]["skipped"] += 1
            elif result["success"]:
                results["summary"]["successful"] += 1
            else:
                results["summary"]["failed"] += 1
        
        # Print summary
        print()
        print(f"{Colors.HEADER}{'='*60}{Colors.ENDC}")
        print(f"{Colors.HEADER}  Summary{Colors.ENDC}")
        print(f"{Colors.HEADER}{'='*60}{Colors.ENDC}")
        print(f"  {Colors.GREEN}Successful: {results['summary']['successful']}{Colors.ENDC}")
        print(f"  {Colors.RED}Failed: {results['summary']['failed']}{Colors.ENDC}")
        print(f"  {Colors.YELLOW}Skipped: {results['summary']['skipped']}{Colors.ENDC}")
        print(f"{Colors.HEADER}{'='*60}{Colors.ENDC}")
        
        # Save results to JSON
        results_file = self.output_dir / "inference_results.json"
        with open(results_file, "w") as f:
            # Remove stdout/stderr from JSON (too verbose)
            clean_results = results.copy()
            for model_name in clean_results["models"]:
                if "stdout" in clean_results["models"][model_name]:
                    del clean_results["models"][model_name]["stdout"]
                if "stderr" in clean_results["models"][model_name]:
                    del clean_results["models"][model_name]["stderr"]
            json.dump(clean_results, f, indent=2)
        
        print(f"\nResults saved to: {results_file}")
        
        return results


# ============================================================================
# Main
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Run all OMR models on the same input image",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python run_all_inference.py --input score.png --output ./results
  python run_all_inference.py --input score.png --models homr,oemer,legato
  python run_all_inference.py --input score.png --device cuda
  python run_all_inference.py --list-models

Available Models:
  - homr: End-to-end OMR using vision transformers
  - oemer: End-to-end OMR system
  - SMT: Sheet Music Transformer
  - legato: LEGATO (requires HuggingFace authentication)
  - Polyphonic-TrOMR: Polyphonic Transformer OMR
  - cadenCV: Python OMR with MIDI output
        """
    )
    
    parser.add_argument(
        "--input", "-i",
        type=str,
        help="Path to input image"
    )
    parser.add_argument(
        "--output", "-o",
        type=str,
        default="./omr_results",
        help="Output directory for results (default: ./omr_results)"
    )
    parser.add_argument(
        "--base-dir", "-b",
        type=str,
        default=None,
        help="Base directory containing model repositories (default: parent of script)"
    )
    parser.add_argument(
        "--models", "-m",
        type=str,
        default=None,
        help="Comma-separated list of models to run (default: all)"
    )
    parser.add_argument(
        "--device", "-d",
        type=str,
        default="cpu",
        choices=["cpu", "cuda"],
        help="Device to use for inference (default: cpu)"
    )
    parser.add_argument(
        "--timeout", "-t",
        type=int,
        default=300,
        help="Timeout per model in seconds (default: 300)"
    )
    parser.add_argument(
        "--list-models",
        action="store_true",
        help="List all available models and exit"
    )
    
    args = parser.parse_args()
    
    if args.list_models:
        print("\nAvailable OMR Models:")
        print("=" * 60)
        for name, config in MODELS_CONFIG.items():
            status = "✓ Ready" if name in READY_MODELS else "⚠ Needs setup"
            deprecated = " (deprecated)" if config.get("deprecated") else ""
            hf = " [HF Auth]" if config.get("requires_hf_auth") else ""
            print(f"  {name:20} - {config['description']}{deprecated}{hf}")
            print(f"  {'':20}   Python {config['python_version']}, Output: {config['output_format']}")
            print(f"  {'':20}   Status: {status}")
            print()
        return
    
    if not args.input:
        parser.error("--input is required")
    
    if not os.path.exists(args.input):
        print_error(f"Input file not found: {args.input}")
        sys.exit(1)
    
    # Determine base directory
    if args.base_dir:
        base_dir = args.base_dir
    else:
        # Assume script is in OMR-Setup, models are in parent
        base_dir = str(Path(__file__).parent.parent)
    
    # Parse models list
    models = None
    if args.models:
        models = [m.strip() for m in args.models.split(",")]
        # Validate models
        for model in models:
            if model not in MODELS_CONFIG:
                print_error(f"Unknown model: {model}")
                print(f"Available models: {', '.join(MODELS_CONFIG.keys())}")
                sys.exit(1)
    
    # Run inference
    runner = OMRModelRunner(base_dir, args.output, args.device)
    results = runner.run_all(args.input, models, args.timeout)
    
    # Exit with error code if any models failed
    if results["summary"]["failed"] > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
