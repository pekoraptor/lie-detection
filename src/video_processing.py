import cv2
import torch
import cv2
import numpy as np
import pandas as pd
from ultralytics import YOLO
from facial_emotion_recognition import EmotionRecognition
import mediapipe as mp
from .config import FACE_DETECTOR_PATH, DEVICE


class VideoProcessor:
    def __init__(self, frame_skip=5):
        self.frame_skip = frame_skip
        self.face_detector = YOLO(FACE_DETECTOR_PATH).to(DEVICE)
        self.emotion_detector = EmotionRecognition(device='gpu' if DEVICE == 'cuda' else 'cpu')
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(static_image_mode=False, refine_landmarks=True, max_num_faces=1)

    def _detect_faces(self, frame):
        results = self.face_detector(frame, verbose=False)
        if not results or results[0].boxes is None:
            return []
        return results[0].boxes.xyxy.int().tolist()

    def _face_crop(self, frame):
        boxes = self._detect_faces(frame)

        for _, box in enumerate(boxes):
            x1, y1, x2, y2 = map(int, box)
            
            h, w = frame.shape[:2]
            x1, y1 = max(0, x1), max(0, y1)
            x2, y2 = min(w, x2), min(h, y2)
            
            face_crop = frame[y1:y2, x1:x2]
            if face_crop.size == 0:
                continue
            
            return face_crop, (x1, y1, x2, y2)
        
        return None, None

    def _resize_frame(self, frame, size=(224, 224)):
        return cv2.resize(frame, size)
    
    def _calculate_head_pose(self, landmarks, frame_width, frame_height):
        model_points = np.array([
            (0.0, 0.0, 0.0),             # Nose tip
            (0.0, -330.0, -65.0),        # Chin
            (-225.0, 170.0, -135.0),     # Left eye left corner
            (225.0, 170.0, -135.0),      # Right eye right corner
            (-150.0, -150.0, -125.0),    # Left Mouth corner
            (150.0, -150.0, -125.0)      # Right mouth corner
        ])

        image_points = []
        for idx in [1, 152, 263, 33, 291, 61]:
            lm = landmarks[idx]
            x, y = lm.x * frame_width, lm.y * frame_height
            image_points.append([x, y])
            
        image_points = np.array(image_points, dtype="double")

        focal_length = frame_width
        center = (frame_width / 2, frame_height / 2)
        camera_matrix = np.array(
            [[focal_length, 0, center[0]],
             [0, focal_length, center[1]],
             [0, 0, 1]], dtype="double"
        )
        dist_coeffs = np.zeros((4, 1)) 

        success, rotation_vector, translation_vector = cv2.solvePnP(
            model_points, image_points, camera_matrix, dist_coeffs, flags=cv2.SOLVEPNP_ITERATIVE
        )

        if not success:
            return {'head_pitch': 0.0, 'head_yaw': 0.0, 'head_roll': 0.0}

        rotation_matrix, _ = cv2.Rodrigues(rotation_vector)
        proj_matrix = np.hstack((rotation_matrix, translation_vector))
        euler_angles = cv2.decomposeProjectionMatrix(proj_matrix)[6]
        
        return {
            'head_pitch': float(euler_angles[0].item()),
            'head_yaw': float(euler_angles[1].item()),
            'head_roll': float(euler_angles[2].item())
        }

    def _geometric_normalization(self, frame, landmarks_objects):
        if not landmarks_objects:
            return frame

        LEFT_EYE_LANDMARKS = [33, 133]
        RIGHT_EYE_LANDMARKS = [362, 263]

        h, w, _ = frame.shape
        
        left_eye = np.array([[landmarks_objects[i].x * w, landmarks_objects[i].y * h] for i in LEFT_EYE_LANDMARKS]).mean(axis=0)
        right_eye = np.array([[landmarks_objects[i].x * w, landmarks_objects[i].y * h] for i in RIGHT_EYE_LANDMARKS]).mean(axis=0)

        dy = right_eye[1] - left_eye[1]
        dx = right_eye[0] - left_eye[0]
        angle = np.degrees(np.arctan2(dy, dx))

        center = tuple(map(float, np.mean([left_eye, right_eye], axis=0)))
        rot_mat = cv2.getRotationMatrix2D(center, angle, 1.0)
        aligned = cv2.warpAffine(frame, rot_mat, (w, h), flags=cv2.INTER_CUBIC)

        return aligned

    def _get_emotion_probs(self, frame):
        if frame.ndim == 3:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        tensor = self.emotion_detector.transform(frame).unsqueeze(0).to(self.emotion_detector.device)

        with torch.no_grad():
            output = self.emotion_detector.network(tensor)
            probs = torch.softmax(output, dim=1).cpu().numpy()[0]

        return {self.emotion_detector.emotions[i]: float(probs[i]) for i in range(len(probs))}

    def _detect_emotions(self, frame):
        return self._get_emotion_probs(frame)

    def _extract_landmarks(self, frame):
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.face_mesh.process(rgb)
        if not results.multi_face_landmarks:
            return None
        return results.multi_face_landmarks[0].landmark

    def _compute_optical_flow(self, prev_gray, gray):
        flow = cv2.calcOpticalFlowFarneback(prev_gray, gray, None,
                                            pyr_scale=0.5, levels=3, winsize=15,
                                            iterations=3, poly_n=5, poly_sigma=1.1, flags=0)
        return {
            "flow_mean_x": float(flow[...,0].mean()),
            "flow_mean_y": float(flow[...,1].mean()),
            "flow_std_x": float(flow[...,0].std()),
            "flow_std_y": float(flow[...,1].std())
        }

    def process_segment(self, video_cap, start_frame, end_frame, label, sample_id):
        results = []
        
        video_cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)
        vid_width = int(video_cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        vid_height = int(video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        
        current_frame = start_frame
        processed_count = 0
        prev_gray = None

        while current_frame <= end_frame:
            ret, frame = video_cap.read()
            if not ret:
                break

            if processed_count % self.frame_skip != 0:
                current_frame += 1
                processed_count += 1
                continue

            face, box = self._face_crop(frame)

            if face is None:
                current_frame += 1
                processed_count += 1
                continue

            x1, y1, x2, y2 = box
            box_center_x = (x1 + x2) / 2 / vid_width
            box_center_y = (y1 + y2) / 2 / vid_height
            box_width = (x2 - x1) / vid_width

            resized_face = self._resize_frame(face)

            landmarks = self._extract_landmarks(resized_face)
            if landmarks is None:
                landmarks_flat = [0.0] * (478*2)
                head_pose = {'head_pitch': 0.0, 'head_yaw': 0.0, 'head_roll': 0.0}
            else:
                landmarks_flat = np.array([(p.x, p.y) for p in landmarks], dtype=np.float32).flatten()
                head_pose = self._calculate_head_pose(landmarks, 224, 224)

            gray = cv2.cvtColor(resized_face, cv2.COLOR_BGR2GRAY)
            
            if prev_gray is not None:
                flow = self._compute_optical_flow(prev_gray, gray)
            else:
                flow = {"flow_mean_x": 0.0, "flow_mean_y": 0.0, "flow_std_x": 0.0, "flow_std_y": 0.0}
            prev_gray = gray

            normalized_face = self._geometric_normalization(resized_face, landmarks)
            emotions = self._detect_emotions(normalized_face)

            results.append({
                'id': sample_id,
                'frame': current_frame,
                'deceptive': label,
                'box_center_x': box_center_x,
                'box_center_y': box_center_y,
                'box_width': box_width,
                **head_pose,
                **{f"lm_{i}": landmarks_flat[i] for i in range(len(landmarks_flat))},
                **emotions,
                **flow
            })

            current_frame += 1
            processed_count += 1

        return results