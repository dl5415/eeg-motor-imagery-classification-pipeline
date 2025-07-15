# EEG Flexion vs Extension Classifier (2021)

This repository contains a full signal processing and machine learning pipeline for decoding hand flexion and hand extension movements from 32-channel EEG data. Models are trained on data from one session and tested on two separate sessions to evaluate cross-session generalization performance.

I am fortunate to have collaborated with Jonathan Madera and Jackson Lightfoot on this project, who built the pipeline with me. 

MI_classification_pipeline.m: The full classification pipeline, including preprocessing on raw EEG, features engineering (extraction & selection), model building and evaluation. 

functions folder: the functions used in the pipeline

selectedChannels.mat: the 32-channel EEG montage used in this project

Project_report.pdf: A report that summarizes the model's performance and our key findings
