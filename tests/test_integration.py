import pytest
import torch
from unittest.mock import patch, MagicMock
from src.prediction_model import DeepLieDetector, RFLieDetector
import numpy as np


@patch("torch.load")
def test_deep_detector_prediction_flow(mock_torch_load, mock_input_tensor):
    mock_checkpoint = {"model_state_dict": MagicMock(), "threshold": 0.6}
    mock_torch_load.return_value = mock_checkpoint

    with patch("src.prediction_model.BiGRUAttention") as MockModelClass:
        mock_model_instance = MockModelClass.return_value
        mock_model_instance.return_value = (torch.tensor([0.5]), torch.randn(1, 20, 1))

        detector = DeepLieDetector("fake_path.pt")
        result = detector.predict(mock_input_tensor)

        assert "probability" in result
        assert "is_deceptive" in result
        assert "attention_weights" in result
        assert result["threshold"] == 0.6
        assert 0.0 <= result["probability"] <= 1.0


@patch("joblib.load")
def test_rf_detector_prediction_flow(mock_joblib_load):
    mock_sklearn_model = MagicMock()
    mock_sklearn_model.predict_proba.return_value = [[0.2, 0.8]]
    mock_joblib_load.return_value = mock_sklearn_model

    with patch("src.prediction_model.preprocess_video_data_rf") as mock_prep:
        mock_prep.return_value = np.zeros((1, 92))

        detector = RFLieDetector("fake_path.joblib")
        result = detector.predict(torch.randn(1, 10, 23))

        assert result["probability"] == 0.8
        assert result["is_deceptive"] is True
        assert result["attention_weights"] is None
