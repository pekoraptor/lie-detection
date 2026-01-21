import torch
import numpy as np
from unittest.mock import patch, MagicMock
from src.features import (
    preprocess_video_data,
    _calculate_distances,
    preprocess_video_data_rf,
)


def test_calculate_distances(sample_video_dataframe):
    dist_features = _calculate_distances(sample_video_dataframe)

    assert dist_features.shape == (len(sample_video_dataframe), 6)
    assert isinstance(dist_features, np.ndarray)


@patch("src.features._load_scalers")
def test_preprocess_video_data(mock_load_scalers, sample_video_dataframe):
    def transform_side_effect(data):
        return np.random.rand(*data.shape)

    mock_scaler = MagicMock()
    mock_scaler.transform.side_effect = transform_side_effect

    mock_load_scalers.return_value = {
        col: mock_scaler
        for col in ["flow_mean_x", "Angry", "head_pitch", "box_center_x"]
    }

    tensor_out = preprocess_video_data(sample_video_dataframe)

    assert isinstance(tensor_out, torch.Tensor)
    assert tensor_out.shape[0] == 1
    assert tensor_out.shape[1] == len(sample_video_dataframe)
    assert tensor_out.shape[2] == 23


def test_preprocess_video_data_rf(mock_input_tensor):
    rf_input = preprocess_video_data_rf(mock_input_tensor)

    assert isinstance(rf_input, np.ndarray)
    assert rf_input.shape == (1, 92)

    assert not np.isnan(rf_input).any()
