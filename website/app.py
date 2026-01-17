import streamlit as st
import cv2
import tempfile
import pandas as pd
import os
import sys
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from website.custom_components import custom_progress_bar


current_dir = Path(__file__).resolve().parent
project_root = current_dir.parent
if str(project_root) not in sys.path:
    sys.path.append(str(project_root))

from src.video_processing import VideoProcessor
from src.features import preprocess_video_data
from src.prediction_model import LieDetector
from src.config import (
    SILESIAN_DEEP_LIE_DETECTOR_PATH,
    FINETUNED_DEEP_LIE_DETECTOR_PATH,
    RF_SILESIAN_LIE_DETECTOR_PATH,
    RF_REAL_LIFE_LIE_DETECTOR_PATH,
)

st.set_page_config(page_title="AI Lie Detector", page_icon="🕵️", layout="centered")

AVAILABLE_MODELS = {
    "BiGRU+Attention trained on Silesian Deception Dataset": SILESIAN_DEEP_LIE_DETECTOR_PATH,
    "BiGRU+Attention fine-tuned on Real-Life Deception Dataset": FINETUNED_DEEP_LIE_DETECTOR_PATH,
    "Random Forest trained on Silesian Deception Dataset": RF_SILESIAN_LIE_DETECTOR_PATH,
    "Random Forest trained on Real-Life Deception Dataset": RF_REAL_LIFE_LIE_DETECTOR_PATH,
}


@st.cache_resource
def load_resources(model_path):
    video_processor = VideoProcessor()
    lie_detector = LieDetector(model_path=model_path)
    return video_processor, lie_detector


def visualize_attention_weights(weights, fps=30, frame_skip=5):
    time_axis = np.arange(len(weights)) / fps * frame_skip

    fig, ax = plt.subplots(figsize=(10, 3))
    ax.plot(time_axis, weights, color="#FF4B4B", linewidth=2)

    ax.fill_between(time_axis, weights, color="#FF4B4B", alpha=0.3)

    ax.set_xlabel("Video Time (seconds)")
    ax.set_ylabel("Model Attention Level")
    ax.set_title("Which moments did the model focus on?")
    ax.grid(True, linestyle="--", alpha=0.5)

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    st.pyplot(fig)

    max_attn_idx = np.argmax(weights)
    peak_time = time_axis[max_attn_idx]
    st.info(f"💡 The model paid the most attention around **{peak_time:.1f} seconds**.")


st.title("🕵️ AI Lie Detector")
st.markdown(
    """
    Upload a video and let the AI analyze it to detect potential deception based on facial cues.
    """
)

with st.sidebar:
    st.header("⚙️ Settings")
    selected_model_name = st.selectbox(
        "Select model for analysis:", options=list(AVAILABLE_MODELS.keys()), index=0
    )
    selected_model_path = AVAILABLE_MODELS[selected_model_name]
    st.caption(f"Loaded model: {selected_model_name}")

try:
    video_processor, lie_detector = load_resources(selected_model_path)
except Exception as e:
    st.error(f"Error loading resources: {e}")
    st.stop()


uploaded_file = st.file_uploader("Upload a video file", type=["mp4", "mov", "avi"])

if uploaded_file is not None:
    st.video(uploaded_file)

    if st.button("Analyze Video"):
        tfile = tempfile.NamedTemporaryFile(delete=False)
        tfile.write(uploaded_file.read())
        video_path = tfile.name

        cap = cv2.VideoCapture(video_path)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)

        progress_bar = st.progress(0)
        status_text = st.empty()

        try:
            status_text.text("Processing video frames...")

            video_processor.frame_skip = int(fps / 30) if fps > 30 else 1

            video_data = video_processor.process_video(
                video_cap=cap,
                start_frame=0,
                end_frame=total_frames,
                label=0,
                sample_id="live_inference",
            )

            progress_bar.progress(50)

            if len(video_data) == 0:
                st.warning("No faces detected in the video. Please try another video.")
            else:
                df = pd.DataFrame(video_data)

                status_text.text("Preprocessing features...")

                input_tensor = preprocess_video_data(df)

                progress_bar.progress(75)
                status_text.text("Predicting deception likelihood...")

                result = lie_detector.predict(input_tensor)

                progress_bar.progress(100)
                status_text.text("Analysis complete!")

                st.divider()

                col1, col2 = st.columns(2)

                with col1:
                    st.metric(
                        "Deception Probability", f"{result['probability']*100:.2f}%"
                    )

                with col2:
                    if result["is_deceptive"]:
                        st.error("Lie Detected")
                    else:
                        st.success("No Lie Detected")

                st.caption(f"Threshold used: {result['threshold']*100:.2f}%")
                custom_progress_bar(result["probability"], result["threshold"])

                if (
                    "attention_weights" in result
                    and result["attention_weights"] is not None
                ):
                    with st.expander("Attention Weights Visualization"):
                        attention_weights = result["attention_weights"].squeeze()
                        fps = cap.get(cv2.CAP_PROP_FPS)
                        if fps == 0:
                            fps = 30
                        visualize_attention_weights(
                            attention_weights, fps, video_processor.frame_skip
                        )
        except Exception as e:
            st.error(f"An error occurred during analysis: {e}")
        finally:
            cap.release()
            os.remove(video_path)
