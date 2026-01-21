import pytest
import torch
import pandas as pd
import numpy as np
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))


@pytest.fixture
def sample_video_dataframe():
    rows = 10
    data = {
        "box_center_x": np.random.rand(rows),
        "box_center_y": np.random.rand(rows),
        "box_width": np.random.rand(rows),
        "head_pitch": np.random.rand(rows),
        "head_yaw": np.random.rand(rows),
        "head_roll": np.random.rand(rows),
        "flow_mean_x": np.random.rand(rows),
        "flow_mean_y": np.random.rand(rows),
        "flow_std_x": np.random.rand(rows),
        "flow_std_y": np.random.rand(rows),
    }
    for i in range(478 * 2):
        data[f"lm_{i}"] = np.random.rand(rows)
    for emotion in ["Angry", "Disgust", "Fear", "Happy", "Neutral", "Sad", "Surprise"]:
        data[emotion] = np.random.rand(rows)

    return pd.DataFrame(data)


@pytest.fixture
def mock_input_tensor():
    return torch.randn(1, 20, 23)
