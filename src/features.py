import joblib
import numpy as np
import torch
from .config import (
    SCALERS_PATH,
    RAW_COLS,
    SCALE_GROUPS,
    HEAD_POSE_COLS,
    BOX_COLS,
    EMOTION_COLS,
    FLOW_COLS,
    LANDMARKS_COLS,
)

FACE_TOP = 10
FACE_BOTTOM = 152
LIPS_V = [13, 14]
LIPS_H = [61, 291]
EYE_L = [159, 145]
EYE_R = [386, 374]
BROW_L = [65, 159]
BROW_R = [295, 386]


def _load_scalers(scalers_path: str):
    return joblib.load(scalers_path)


def calculate_distances(df, dist_scale=100.0, zero_center=True):
    landmark_data = df.filter(regex="^lm_").values.astype(np.float32)

    if landmark_data.shape[1] == 0:
        return np.zeros((len(df), 6), dtype=np.float32)

    seq_len = len(df)
    num_landmarks = landmark_data.shape[1] // 2

    try:
        landmarks = landmark_data.reshape(seq_len, num_landmarks, 2)

        face_height = np.linalg.norm(
            landmarks[:, FACE_TOP] - landmarks[:, FACE_BOTTOM], axis=1
        )
        face_height = np.clip(face_height, 1e-6, None)

        def get_dist(idx1, idx2):
            return (
                np.linalg.norm(landmarks[:, idx1] - landmarks[:, idx2], axis=1)
                / face_height
            )

        dist_features = np.stack(
            [
                get_dist(LIPS_V[0], LIPS_V[1]),
                get_dist(LIPS_H[0], LIPS_H[1]),
                get_dist(EYE_L[0], EYE_L[1]),
                get_dist(EYE_R[0], EYE_R[1]),
                get_dist(BROW_L[0], BROW_L[1]),
                get_dist(BROW_R[0], BROW_R[1]),
            ],
            axis=1,
        )

        if zero_center:
            dist_features = dist_features - np.mean(dist_features, axis=0)

        return dist_features * dist_scale

    except ValueError:
        return np.zeros((len(df), 6), dtype=np.float32)


def preprocess_video_data(df):
    df = df.copy()

    try:
        scalers = _load_scalers(SCALERS_PATH)
    except FileNotFoundError:
        raise FileNotFoundError(
            f"Scalers file not found at {SCALERS_PATH}. Please ensure the file exists."
        )

    for group in SCALE_GROUPS:
        first_col_name = group[0]
        if first_col_name in scalers:
            scaler = scalers[first_col_name]
            df[group] = scaler.transform(df[group].values)

    smooth_cols = HEAD_POSE_COLS + BOX_COLS
    for col in smooth_cols:
        if col in df.columns:
            df[col] = df[col].bfill().fillna(0).rolling(window=5, min_periods=1).mean()

    features_list = []

    raw_data = df[RAW_COLS].values.astype(np.float32)
    raw_data = np.nan_to_num(raw_data, nan=0.0)
    features_list.append(raw_data)

    dist_data = calculate_distances(df)
    features_list.append(dist_data)

    box_data = df[BOX_COLS].values.astype(np.float32)
    box_data = np.nan_to_num(box_data, nan=0.0)
    velocity_scale = 100.0
    box_velocity = np.diff(box_data, axis=0, prepend=box_data[:1])
    features_list.append(box_velocity * velocity_scale)

    X = np.concatenate(features_list, axis=1)
    X = np.nan_to_num(X, nan=0.0)

    return torch.tensor(X, dtype=torch.float32).unsqueeze(0)


def preprocess_video_data_rf(tensor_data):
    X_seq = tensor_data.squeeze(0).numpy()

    if X_seq.size == 0:
        return np.zeros((1, X_seq.shape[1] * 4), dtype=np.float32)

    mu = np.mean(X_seq, axis=0)
    sigma = np.std(X_seq, axis=0)
    mx = np.max(X_seq, axis=0)
    rng = mx - np.min(X_seq, axis=0)

    sample_stats = np.concatenate([mu, sigma, mx, rng])

    return sample_stats.reshape(1, -1)
