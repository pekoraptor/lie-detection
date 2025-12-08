import torch
from .config import DEVICE, LIE_DETECTOR_PATH
from .models import LieDetectionModel

class LieDetector:
    def __init__(self, model_path=LIE_DETECTOR_PATH):
        self.device = DEVICE
        self.model_path = model_path
        self.model = None
        self.threshold = 0.5
        self._load_model()
    
    def _load_model(self):
        try:
            checkpoint = torch.load(self.model_path, map_location=self.device)
            self.model = LieDetectionModel(input_dim=23, hidden_dim=32, dropout=0.5).to(self.device)
            self.model.load_state_dict(checkpoint['model_state_dict'])
            self.model.eval()
            self.threshold = checkpoint.get('threshold', 0.5)
        except Exception as e:
            raise RuntimeError(f"Failed to load model from {self.model_path}: {e}")

    def predict(self, input_tensor):
        seq_len = torch.tensor([input_tensor.shape[1]]).cpu()
        input_tensor = input_tensor.to(self.device)
        with torch.no_grad():
            logits, attention_weights = self.model(input_tensor, seq_len)
            prob = torch.sigmoid(logits).cpu().item()
            is_deceptive = prob >= self.threshold
        
            return {
                'probability': prob,
                'is_deceptive': is_deceptive,
                'threshold': self.threshold,
                'attention_weights': attention_weights.cpu().numpy()
            }