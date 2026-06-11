# EEG-Based-Emotion-Classification Using Higuchi Fractal Dimension and K-Nearest Neighbor 
# Overview
This project aims to classify human emotional states using EEG (Electroencephalogram) signals. Higuchi Fractal Dimension (HFD) is used for feature extraction, while the K-Nearest Neighbor (KNN) algorithm is used for emotion classification.

# Features
- EEG signal preprocessing
- Feature extraction using Higuchi Fractal Dimension (HFD)
- Emotion classification using K-Nearest Neighbor (KNN)
- Performance evaluation using classification metrics
- Data visualization and analysis using MATLAB

# Workflow
- EEG data acquisition
- Signal preprocessing
- Feature extraction using HFD
- KNN model training
- Emotion classification
- Performance evaluation

# Dataset
The original EEG dataset is not included in this repository due to storage and privacy considerations. Only the source code and project documentation are provided.

# Results
The proposed EEG emotion classification system successfully distinguished Relaxed and Neutral states using a combination of Discrete Wavelet Transform (DWT-db4), Higuchi Fractal Dimension (HFD), and K-Nearest Neighbor (KNN).

Performance
- Cross-validation Accuracy: 91.67%
- Precision: 85.71%
- Recall: 100%

Key Findings
- DWT-db4 effectively extracted relevant EEG signal components, particularly Beta wave activity associated with Relaxed and Neutral conditions.
- HFD successfully represented signal complexity and improved class separability.
- KNN demonstrated strong classification performance and stable prediction capability during validation.

Limitations
Testing accuracy decreased to 62.5% due to several False Positive predictions, where Neutral signals were classified as Relaxed. This behavior was likely caused by:
- Eye blink artifacts
- Muscle movement noise
- Variations in participant concentration during EEG acquisition

Despite these limitations, the results indicate that a lightweight EEG processing pipeline based on DWT, HFD, and KNN can effectively identify basic emotional states using a single-channel EEG device.

<img width="570" height="403" alt="DataTraining" src="https://github.com/user-attachments/assets/08328c79-94f9-4127-9f6c-af1da5de8636" />
<img width="588" height="300" alt="DataUji" src="https://github.com/user-attachments/assets/d9bac662-8bc0-4dfa-ac79-48588a47844f" />

# Authors
- Andan Riski Mustari 			      235150301111002
- Maulidiah Yasmin			        	235150301111006
- Muhammad Zurin Hanandi Abdillah	235150307111010
- Adhitya Noer Effendi 	       		235150307111024
