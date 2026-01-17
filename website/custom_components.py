import streamlit as st


def custom_progress_bar(probability, threshold):
    bar_color = "#FF4B4B" if probability >= threshold else "#00CC96"

    prob_pct = min(max(probability * 100, 0), 100)
    thresh_pct = min(max(threshold * 100, 0), 100)

    st.markdown(
        f"""
    <style>
        .progress-container {{
            position: relative;
            width: 100%;
            height: 8px;
            background-color: rgba(255, 255, 255, 0.1); /* Ciemne tło paska */
            border-radius: 10px;
            margin-top: 5px;
            margin-bottom: 30px;
        }}
        .progress-bar {{
            height: 100%;
            background-color: {bar_color};
            border-radius: 10px;
            width: {prob_pct}%;
            transition: width 0.5s ease-in-out;
        }}
        .threshold-line {{
            position: absolute;
            left: {thresh_pct}%;
            top: -4px;
            bottom: -4px;
            width: 2px;
            background-color: #FFFFFF;
            z-index: 10;
            box-shadow: 0 0 5px rgba(0,0,0,0.5);
        }}
        .threshold-label {{
            position: absolute;
            left: {thresh_pct}%;
            top: -20px;
            transform: translateX(-50%);
            font-size: 0.8em;
            color: #ccc;
        }}
    </style>
    <div class="progress-container">
        <div class="progress-bar"></div>
        <div class="threshold-line" title="Threshold: {threshold*100:.2f}%"></div>
    </div>
    """,
        unsafe_allow_html=True,
    )
