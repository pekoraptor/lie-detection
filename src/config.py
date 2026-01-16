from pathlib import Path
import os
import torch


def find_project_root(anchor_file="LICENSE"):
    current_path = Path(os.getcwd())
    for parent in [current_path] + list(current_path.parents):
        if (parent / anchor_file).exists():
            return parent
    raise FileNotFoundError(f"Could not find project root containing {anchor_file}")


PROJECT_ROOT = find_project_root()
SILESIAN_DEEP_LIE_DETECTOR_PATH = (
    PROJECT_ROOT / "model_weights" / "bigru_attention_silesian.pt"
)
FINETUNED_DEEP_LIE_DETECTOR_PATH = (
    PROJECT_ROOT / "model_weights" / "bigru_attention_real_life_finetuned.pt"
)
RF_SILESIAN_LIE_DETECTOR_PATH = PROJECT_ROOT / "model_weights" / "rf_silesian.joblib"
RF_REAL_LIFE_LIE_DETECTOR_PATH = PROJECT_ROOT / "model_weights" / "rf_real_life.joblib"

FACE_DETECTOR_PATH = PROJECT_ROOT / "model_weights" / "yolov8n-face.pt"
SCALERS_PATH = PROJECT_ROOT / "model_weights" / "scalers.joblib"

if torch.cuda.is_available():
    DEVICE = torch.device("cuda")
elif torch.backends.mps.is_available():
    DEVICE = torch.device("mps")
else:
    DEVICE = torch.device("cpu")

print(f"Using device: {DEVICE}")

LANDMARKS_COLS = [f"lm_{i}" for i in range(478 * 2)]
EMOTION_COLS = ["Angry", "Disgust", "Fear", "Happy", "Neutral", "Sad", "Surprise"]
FLOW_COLS = ["flow_mean_x", "flow_mean_y", "flow_std_x", "flow_std_y"]
HEAD_POSE_COLS = ["head_pitch", "head_yaw", "head_roll"]
BOX_COLS = ["box_center_x", "box_center_y", "box_width"]

SCALE_GROUPS = [FLOW_COLS, EMOTION_COLS, HEAD_POSE_COLS, BOX_COLS]

RAW_COLS = FLOW_COLS + EMOTION_COLS + HEAD_POSE_COLS
