clear
close all
clc

%% Import Data
addpath(genpath(strcat(pwd,'/eeglab2020_0/')));
addpath(strcat(pwd,'/functions/'));
load('data/p3_subjectData.mat');

%% M1 channels
%Only consider M1 (motor related channels) for features extraction
Subject1_chan = {'FC5', 'FC1', 'C3', 'CP5', 'CP1'};
Subject2_chan = {'FC6', 'FC2', 'C4', 'CP6', 'CP2'};
Rec_channels = subjectData(1).pre(1).hdr.Label;
sub1_chan = find(ismember(Rec_channels, Subject1_chan));
sub2_chan = find(ismember(Rec_channels, Subject2_chan));
ROI = Rec_channels(ismember(Rec_channels, M1_channels));
%Note, this is not used for now -> as it is probably not rigorous
test_channels = {'C5','C3','CZ'};
ROI_idx = find(ismember(Rec_channels, M1_channels));
test_idx = find(ismember(Rec_channels, test_channels));
test_ROI = Rec_channels(test_idx);
load('data/selectedChannels.mat')

%% Filter Raw Data (pre-processing)
%temporal_filter(subjectData, af1, af2, bf1, bf2, pf1,pf2, N); pf1, pf2
%preprocessing freq bands on raw data (1-30Hz)
subjectData = temporal_filter(subjectData, 8, 12, 18, 22, 1, 30, 5);
%Spatial filter: CAR
subjectData = spatial_filter(subjectData);
% Adding the moving average filter reduces signal power too much
subjectData = m_avg(subjectData,1,512);
save('data/filtered.mat', 'subjectData')

%% Extract Trials
%data descriptions: 2 subjects, 2 sessions (pre and post), 2runs, 32 channels
%Labels: 
% flex = 1;
% ext = 2;
% rest = 3;
load('data/filtered.mat')
% 7s trial -> task cue(2s) + task execution(4s) + 1s post-trial
%Extract alpha, beta and preprocessed raw trials (and their power)
Endtime = 7;
trialData = extract_trials(subjectData, Endtime);
save('data/trials.mat', 'trialData', '-v7.3')

%% Explore Data
load('data/trials.mat');
%Trial(epoch) time
Endtime = 7;
Fs = subjectData(1).pre(1).hdr.fs;
TrialSample = -2*Fs+1:(Endtime-2)*Fs;
TrialTime = TrialSample./Fs;
TrialOnset = find(TrialTime == 0);
save('data/TrialTime.mat', 'TrialTime')

Fs = subjectData(1).pre(1).hdr.fs;
chan_labels = trialData(1).pre(1).electrodes;

%ERD computation (baseline referencing)
[ERD_data, Sub1_artef, Sub2_artef] = ERDcompute(trialData, TrialOnset, Fs);
desired_label_ERD = {'ERD_alpha','ERD_beta'};
save('data/ERD_data.mat', 'ERD_data')
%[ERD_data] = ERDcompute_artrem(trialData, TrialOnset, Fs, Sub1_artef, Sub2_artef);

%% Trial removal -> based on average ERD analysis 
load('data/trials.mat');
Art_indx.sub1 = Sub1_artef;
Art_indx.sub2 = Sub2_artef;
save('data/Art_indx.mat', 'Art_indx')
trialData = trial_rem (trialData, Art_indx); 
save('data/trials_tr_rm.mat', 'trialData', '-v7.3')
[ERD_data, ~, ~] = ERDcompute(trialData, TrialOnset, Fs);
save('data/ERD_data_tr_rm.mat', 'ERD_data')

%% ERD analysis
%task 1: flexion, task 2: extension
close all;
load('data/ERD_data_tr_rm.mat');
load('data/Art_indx.mat'); %for equal ttest comparison
channel.sub1 = find(ismember(chan_labels, Subject1_chan)); channel.sub2 = find(ismember(chan_labels, Subject2_chan));

[ERD_subject, sig_h, sig_p, prepost_h, prepost_p] = ERDanalysis(ERD_data, channel, TrialOnset, Fs, chan_labels, Art_indx);

%% Step 1: Topo flow of alpha, beta (power?) for all channels before and
% after TESS -> visualisation -> ROI. 
% 6 Topos per subject task, each covering a 1s window from task cue to task
% end.
window_size = 1; % seconds ie 0-1, 1-2, etc.
num_channels = length(Rec_channels);
plotting_topos(ERD_data,selectedChannels,window_size,desired_label_ERD,Fs,num_channels)

%% Condensed topo plots
close all
load('data/ERD_data_tr_rm.mat')
load('selectedChannels.mat')
start_time = 2;
duration = 4;
limits = [-50 50];
file_type = '.png';
condensed_topos(ERD_data, selectedChannels, start_time, duration, limits, Fs, file_type)

%% Topo video
% This section will save videos for the whole trial for a subject of
% session 1 vs session 2 for flexion, extension, and rest for both alpha
% and beta % ERD. 6 videos total! Each video is comprised of 6 topo plots
% each topo shows the time evolution for average task signals in a session.
topoStruct = reArrangeERD4Topo(ERD_data);
topoVideoMaker(topoStruct,selectedChannels,TrialTime);

%% Plotting average time windows
% num_channels = length(Rec_channels);
% window_num = 2;
% %window size in sec, window_num is window you want a topo of eg 2 = from 1-2 seconds
% window = [window_size window_num]; 
% topo_limits = [-50 50]; % limits for the power for the topo plot looks good for alpha
% topo_feat_plot(topoStruct,selectedChannels,window,Fs,num_channels,topo_limits)
%
%Step 2: TF plot of GA of power spectra of selected channels (before and after TESS)
%Input: pre-processed eeg, channel input as 1x2 integer (2 subjects)
%Sub1 right, Sub2 left
close all
%Channel selected for each subject and task
%CPT is a good channel for Sub 1 Flexion (ERD seen). 
load('data/trials.mat');
chan_labels = trialData(1).pre(1).electrodes;
Fs = subjectData(1).pre(1).hdr.fs;
%Extended trial time
Endtime = 8.5;
TrialSample = -3.5*Fs+1:(Endtime-3.5)*Fs;
TrialTime = TrialSample./Fs;
%Fixation, Task cue, Task execution, Task end
Marker.timestamp = [1, 1.5*Fs, 3.5*Fs,7.5*Fs];
Marker.stamp_name = {'Fixation', 'Task cue', 'Task execution', 'Task end'};
%task 1: flexion, task 2: extension
%channel.sub1 = find(ismember(chan_labels, Subject1_chan)); channel.sub2 = find(ismember(chan_labels, Subject2_chan));
%TF plotting
channel.sub1 = 15; channel.sub2 = 23;
sub_TF = TFcompute(trialData, Fs, channel, TrialTime, Marker);

%% FC Plotting
load('data/trials.mat');
signal_label = [{'alpha','beta','pre_raw','alpha_p','beta_p','pre_raw_p'}];
FC = FC_lagged(trialData,1:32,signal_label([1 2]));
load('data/chan_pairs_idx.mat');
sub1_channum = [126,127,128,139,142,145,146,302,317,320];
sub2_channum = [172,174,176,177,253,330,332,340,343,332];
channel_num = [sub1_channum; sub2_channum];
FC_cluster(FC,Rec_channels,idx,signal_label([1 2]),channel_num);

%% Grand averages
%Step 3: GA of selected channels (power?) (before and after TESS)
% We need to choose the correct eeg channels before we plot the grand
% averages
signal_label = [{'alpha_extended','beta_extended'}];
all_channel_idx = 1:numel(Rec_channels);
grandAvgSignals = grand_avg_squaring(trialData,all_channel_idx,signal_label);
channel_num = [sub1_chan'; sub2_chan'];
plot_gA(grandAvgSignals,signal_label,channel_num, TrialTime,Marker);

%% Feature extraction
%Features extraction and classification should follow literature on hand extension/flexion MI
load('data/trials.mat');
load('data/TrialTime.mat');
load('data/Art_indx.mat');
load('data/p3_subjectData.mat');
Fs = subjectData(1).pre(1).hdr.fs;

motor_channels = struct;
motor_channels(1).labels = {'FC5', 'FC1', 'FC2', 'FC6', 'T7', 'C3', 'Cz', 'C4', 'T8', 'CP5', 'CP1', 'CP2', 'CP6'};
motor_channels(2).labels = {'FC5', 'FC1', 'FC2', 'FC6', 'T7', 'C3', 'Cz', 'C4', 'T8', 'CP5', 'CP1', 'CP2', 'CP6'};

%Features extraction (WIP: sanity check needed)
%Features extracted from all channels, across 7s trial period. 
%Outputs: sub_feat (TF features extracted), sub_feat_labels(name of features: channel, time, freq)
%cat_trials_labels (combined trials -> 75 each sub, session, and labels)
features = struct;
[features.values, features.labels, features.trials] = featextract(trialData, Fs, TrialTime, motor_channels); 
save('data/all_features_ch_rm.mat', 'features')
%4992 features => 12 x 13 x 32
features_rm = features_rem(features, Art_indx); 
save('data/all_features_ch_rm_tr_rm.mat', 'features_rm')

%% Feature extraction for contralateral only
load('data/trials.mat');
load('data/TrialTime.mat');
load('data/Art_indx.mat');
load('data/p3_subjectData.mat');
Fs = subjectData(1).pre(1).hdr.fs;

motor_channels = struct;
motor_channels(1).labels = {'FC5', 'FC1', 'T7', 'C3', 'Cz', 'CP5', 'CP1'};
motor_channels(2).labels = {'FC2', 'FC6', 'Cz', 'C4', 'T8', 'CP2', 'CP6'};

features = struct;
[features.values, features.labels, features.trials] = featextract(trialData, Fs, TrialTime, motor_channels); 
save('data/all_features_contra.mat', 'features')

features_rm = features_rem(features, Art_indx); 
save('data/all_features_contra_tr_rm.mat', 'features_rm')

%% Hard coding run ranges
run_ranges = struct;
for s = 1:2
    for ses = 1:2
        if s == 1 && ses == 1
            run_ranges(s,ses,1).vals = 1:44;
            run_ranges(s,ses,2).vals = 45:72;
        else
            if s == 2 && ses == 2
                run_ranges(s,ses,1).vals = 1:44;
                run_ranges(s,ses,2).vals = 45:71;
            else
                run_ranges(s,ses,1).vals = 1:45;
                run_ranges(s,ses,2).vals = 46:75;
            end
        end
    end
end

%% Feature selection (md)
load('data/all_features_ch_rm_tr_rm.mat')
selected = select_features_md(features_rm, run_ranges, 5);
save('data/selected_features_md_5.mat', 'selected')

%% Feature selection (md contra only)
load('data/all_features_contra_tr_rm.mat')
selected = select_features_md(features_rm, run_ranges, 5);
save('data/selected_features_contra_md_5.mat', 'selected')

%% Feature selection (fisher)
load('data/all_features_ch_rm_tr_rm.mat')
selected = select_features_fisher(features_rm, run_ranges, 15); 
save('data/selected_features_fisher_15.mat', 'selected')

%% Feature selection (fisher contra only)
load('data/all_features_contra_tr_rm.mat')
selected = select_features_fisher(features_rm, run_ranges, 15); 
save('data/selected_features_contra_fisher_15.mat', 'selected')

%% Feature analysis (md)
load('data/selected_features_md_5.mat')
contra_channels = struct;
contra_channels(1).labels = {'FC5', 'FC1', 'T7', 'C3', 'Cz', 'CP5', 'CP1'};
contra_channels(2).labels = {'FC2', 'FC6', 'Cz', 'C4', 'T8', 'CP2', 'CP6'};
ipsi_channels(1).labels = {'FC2', 'FC6', 'Cz', 'C4', 'T8', 'CP2', 'CP6'};
ipsi_channels(2).labels = {'FC5', 'FC1', 'T7', 'C3', 'Cz', 'CP5', 'CP1'};
alpha = {'7', '9', '11', '13'};
beta = {'17', '19', '21', '23', '25', '27', '29'};
cue_times = {'-1.9', '-1.4', '-0.9', '-0.4'};
task_times = {'0.0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0', '3.5'};
analysis = feature_analysis(selected, contra_channels, ipsi_channels, alpha, beta, cue_times, task_times);
save('results/feature_analysis_md.mat', 'analysis')

%% Feature analysis (fisher)
load('data/selected_features_fisher_15.mat')
contra_channels = struct;
contra_channels(1).labels = {'FC5', 'FC1', 'T7', 'C3', 'Cz', 'CP5', 'CP1'};
contra_channels(2).labels = {'FC2', 'FC6', 'Cz', 'C4', 'T8', 'CP2', 'CP6'};
ipsi_channels(1).labels = {'FC2', 'FC6', 'Cz', 'C4', 'T8', 'CP2', 'CP6'};
ipsi_channels(2).labels = {'FC5', 'FC1', 'T7', 'C3', 'Cz', 'CP5', 'CP1'};
alpha = {'7', '9', '11', '13'};
beta = {'17', '19', '21', '23', '25', '27', '29'};
cue_times = {'-1.9', '-1.4', '-0.9', '-0.4'};
task_times = {'0.0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0', '3.5'};
analysis = feature_analysis(selected, contra_channels, ipsi_channels, alpha, beta, cue_times, task_times);
save('results/feature_analysis_fish.mat', 'analysis')

%% Classification & Confusion (md)
close all
load('data/selected_features_md_5.mat')
disp('***')
CV = lda_cross_validation(selected);
save('results/CV_md.mat', 'CV')
file_type = '_md.png';
plot_all_confusions(CV, file_type)

%% Classification & Confusion (md contra only)
close all
load('data/selected_features_contra_md_5.mat')
disp('***')
CV = lda_cross_validation(selected);
save('results/CV_contra_md.mat', 'CV')
file_type = '_contra_md_small.png';
plot_all_confusions(CV, file_type)

%% Classification & Confusion (fisher)
close all
load('data/selected_features_fisher_15.mat')
disp('***')
CV = lda_cross_validation(selected);
save('results/CV_fish.mat', 'CV')
file_type = '_fish.png';
plot_all_confusions(CV, file_type)

%% Classification & Confusion (fisher contra only)
close all
load('data/selected_features_contra_fisher_15.mat')
disp('***')
CV = lda_cross_validation(selected);
save('results/CV_contra_fish.mat', 'CV')
file_type = '_contra_fish_small.png';
plot_all_confusions(CV, file_type)

%% CV Plotting
close all
file_type = '.png';
fig_cv = figure('units', 'normalized', 'Position', [.1, .1, .5, .8]);

load('results/CV_md.mat')
subplot(2,2,1)
plot_cv_bar(CV, 'Mahalanobis Selection (All Motor)')

load('results/CV_contra_md.mat')
subplot(2,2,2)
plot_cv_bar(CV, 'Mahalanobis Selection (Contralateral)')

load('results/CV_fish.mat')
subplot(2,2,3)
plot_cv_bar(CV, 'Fisher Selection (All Motor)')

load('results/CV_contra_fish.mat')
subplot(2,2,4)
plot_cv_bar(CV, 'Fisher Selection (Contralateral)')

sgtitle('LDA Cross Validation Results', 'FontSize', 12);
exportgraphics(fig_cv, strcat('Graphs\', 'CV_bar_LDA', file_type));

%% Chance level
% even with removed trials still effectively 33%
chance = struct;
for s = 1:2 %subjects
    %pre: chance compute
    chance(s).pre = chance_compute(features_rm.trials(s).pre_label); 
    %post: chance compute
    chance(s).post = chance_compute(features_rm.trials(s).post_label);
end
