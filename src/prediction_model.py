import torch
import joblib
from abc import ABC, abstractmethod
import numpy as np

from src.features import preprocess_video_data_rf
from .config import DEVICE, LIE_DETECTOR_PATH
from .models import BiGruAttention


class BaseLieDetector(ABC):
    def __init__(self, model_path):
        self.model_path = model_path
        self.model = None
        self.threshold = 0.5
        self.device = DEVICE
        self._load_model()

    @abstractmethod
    def _load_model(self):
        pass

    @abstractmethod
    def predict(self, input_tensor):
        pass


class DeepLieDetector(BaseLieDetector):
    def _load_model(self):
        try:
            checkpoint = torch.load(
                self.model_path,
                map_location=torch.device("cpu"),
                weights_only=False,
            )

            self.model = BiGruAttention(input_dim=23, hidden_dim=16, dropout=0.4)
            self.model.load_state_dict(checkpoint["model_state_dict"])
            self.model.to(self.device)
            self.model.eval()

            self.threshold = checkpoint.get("threshold", 0.5)
            print(f"Successfully loaded model to {self.device}")

        except Exception as e:
            raise RuntimeError(f"Failed to load model: {e}")

    def predict(self, input_tensor):
        if not isinstance(input_tensor, torch.Tensor):
            input_tensor = torch.tensor(input_tensor, dtype=torch.float32)

        seq_len = torch.tensor([input_tensor.shape[1]]).cpu()
        input_tensor = input_tensor.to(self.device)

        with torch.no_grad():
            logits, attention_weights = self.model(input_tensor, seq_len)
            prob = torch.sigmoid(logits).cpu().item()
            is_deceptive = prob >= self.threshold

            return {
                "probability": prob,
                "is_deceptive": is_deceptive,
                "threshold": self.threshold,
                "attention_weights": attention_weights.cpu().numpy(),
            }


class RFLieDetector(BaseLieDetector):
    def _load_model(self):
        try:
            loaded_data = joblib.load(self.model_path)

            if isinstance(loaded_data, dict):
                self.model = loaded_data.get("model")
                self.threshold = loaded_data.get("threshold", 0.5)
            else:
                self.model = loaded_data
                self.threshold = 0.5

            print(f"Successfully loaded Random Forest from {self.model_path}")
        except Exception as e:
            raise RuntimeError(f"Failed to load RF model: {e}")

    def predict(self, input_tensor):
        features = preprocess_video_data_rf(input_tensor)

        probs = self.model.predict_proba(features)
        prob_deceptive = probs[0][1]
        is_deceptive = prob_deceptive >= self.threshold

        return {
            "probability": prob_deceptive,
            "is_deceptive": is_deceptive,
            "threshold": self.threshold,
            "attention_weights": None,
        }


def LieDetector(model_path, model_type="auto"):
    if model_type == "rf" or str(model_path).endswith(".joblib"):
        return RFLieDetector(model_path)
    else:
        return DeepLieDetector(model_path)
