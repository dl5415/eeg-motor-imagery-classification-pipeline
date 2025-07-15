%Feat extract from all channels

%Returned: TF features (all channels), labels (names) of these features,
%and labels of trials
function [sub_feat, sub_feat_labels, sub] = featextract(data, Fs, TrialTime, motor_channels)
ds_factor_temp = 256;
ds_factor_freq = 2;
% Freq to compute spectral data
F = 5:30;
F_label = 5:ds_factor_freq:30;
labels = [1, 2, 3]; %flex = 1; ext = 2; rest = 3;
tasks = {'Flexion', 'Extension', 'Rest'};
channels = data(1).pre(1).electrodes;

%Concatenate runs together (75 trials per subject per session) - use
%preprocessed EEG
%Neglect the post-task (1s)
Task_end = Fs * 6;
%
sub(1).pre_eeg = cat(1, data(1).pre(1).pre_raw (:,1:Task_end,:), data(1).pre(2).pre_raw(:,1:Task_end,:));
sub(1).pre_label = cat(1, data(1).pre(1).labels, data(1).pre(2).labels);
sub(2).pre_eeg = cat(1, data(2).pre(1).pre_raw(:,1:Task_end,:), data(2).pre(2).pre_raw(:,1:Task_end,:));
sub(2).pre_label = cat(1, data(2).pre(1).labels, data(2).pre(2).labels);
sub(1).post_eeg = cat(1, data(1).post(1).pre_raw(:,1:Task_end,:), data(1).post(2).pre_raw(:,1:Task_end,:));
sub(1).post_label = cat(1, data(1).post(1).labels, data(1).post(2).labels);
sub(2).post_eeg = cat(1, data(2).post(1).pre_raw(:,1:Task_end,:), data(2).post(2).pre_raw(:,1:Task_end,:));
sub(2).post_label = cat(1, data(2).post(1).labels, data(2).post(2).labels);


%Feat extract
for s = 1:2 %subjects
    sub_feat(s).pre = []; sub_feat(s).post = [];
    %labels will be the same for pre and post
    sub_feat_labels(s).sig = {};
    % use only specific motor channels
    motor_idx = find(ismember(channels, motor_channels(s).labels));
    
    for i = 1:length(sub(s).pre_label) %doesn't matter which labels, 75 trials
        tmp(s).pre = []; tmp(s).post = [];
        tmp_label(s).sig = {};
        for k = 1:length(motor_idx)
            %TF via cwt (Pre)
            coefsi_pre = cwt(sub(s).pre_eeg(i,:,motor_idx(k)), centfrq('cmor1 -1 ')*Fs./F, 'cmor1 -1 ');
            %Mag as feature, divide into time frequency blocks, average the
            %Mag of coeffs in each block
            feat = extract_wav_features(coefsi_pre, ds_factor_temp, ds_factor_freq);
            %labels
            labels = cell (size(feat));
            for p1 = 1:size(labels, 1)
                for p2 = 1:size(labels,2)
                    %t_label = sprintfc('t:%d ',TrialTime);
                    labels{p1,p2} = sprintf('C:%s F:%s T:%s',string(channels(motor_idx(k))),num2str(F_label(p1)), num2str(TrialTime(ds_factor_temp*(p2-1)+1)));
                end
            end
            tmp(s).pre = [tmp(s).pre  reshape(feat.',1,[])];
            tmp_label(s).sig = [tmp_label(s).sig  reshape(labels.',1,[])];
        end
        for k = 1:length(motor_idx)
            %Post
            coefsi_post = cwt(sub(s).post_eeg(i,:,motor_idx(k)),centfrq('cmor1 -1 ')*Fs./F, 'cmor1 -1 ');
            feat = extract_wav_features(coefsi_post, ds_factor_temp, ds_factor_freq);
            tmp(s).post = [tmp(s).post  reshape(feat.',1,[])];
        end 
        %Concatenate features from each trial
        sub_feat(s).pre = [sub_feat(s).pre; tmp(s).pre]; 
        sub_feat(s).post = [sub_feat(s).post; tmp(s).post];
        sub_feat_labels(s).sig= [sub_feat_labels(s).sig ;tmp_label(s).sig];
        %sub_labels(s).sig =cellfun(@(x,y) [x;y], sub_labels(s).sig, tmp_label(s).sig, 'UniformOutput', false);
    end
end
end

function feat = extract_wav_features(coeffs, ds_factor_temp, ds_factor_freq)
    feat = zeros(ceil(size(coeffs, 1)/ds_factor_freq), ceil(size(coeffs, 2)/ds_factor_temp));
    for i = 1:size(feat, 1) %freq (rows)
        for j = 1:size(feat, 2) %time (cols)
            feat(i,j) = mean(abs(coeffs((i-1)*ds_factor_freq+1 : i*ds_factor_freq , (j-1)*ds_factor_temp+1 : j*ds_factor_temp)), 'all');
        end
    end
end

