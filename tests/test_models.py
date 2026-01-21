import torch
from src.models import BiGRUAttention


def test_bigru_initialization():
    model = BiGRUAttention(input_dim=23, hidden_dim=16, num_layers=2)
    assert model.gru.input_size == 23
    assert model.gru.hidden_size == 16
    assert model.gru.num_layers == 2
    assert model.gru.bidirectional is True


def test_bigru_forward_pass():
    batch_size = 4
    seq_len = 50
    input_dim = 23

    model = BiGRUAttention(input_dim=input_dim, hidden_dim=16)
    dummy_input = torch.randn(batch_size, seq_len, input_dim)
    lengths = torch.tensor([seq_len] * batch_size)

    logits, weights = model(dummy_input, lengths)

    assert logits.shape == (batch_size,)
    assert weights.shape == (batch_size, seq_len, 1)


def test_attention_weights_sum():
    model = BiGRUAttention(input_dim=23, hidden_dim=16)
    dummy_input = torch.randn(1, 10, 23)
    lengths = torch.tensor([10])

    _, weights = model(dummy_input, lengths)

    weights_sum = weights.sum(dim=1).item()
    assert abs(weights_sum - 1.0) < 1e-5
