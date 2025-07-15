function [grandAvgSignals] = FC_lagged(trialData,channelSelect,signal_label)
%GRADN_AVG Summary of this function goes here
%   Detailed explanation goes here
subjects = length(trialData); % number of subjects
sessions = fieldnames(trialData); % number of sessions ie. pre and post
sessionData = getSession(trialData); % concatenate all runs into a session before grand averaging
grandAvgSignals = struct;
for sub_iter=1:subjects % number of subjects
    for sess_iter=1:length(sessions)
        for signal_iter=1:length(signal_label)
            labels = sessionData(sub_iter).(sessions{sess_iter}).labels; % labels of task within session
            signal = sessionData(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter});
            [idx_flex, idx_ext, idx_rest] = task_idx(labels); % find indices of each task to break up signal
%             signal = m_avg(signal);
            % average the signal data with task indices and standard error
            [fc,fc_trials] = fc_lag(idx_flex, idx_ext, idx_rest,signal,channelSelect); 
            % bundle the g_avg values into subject,session, signal type
            % structure
            grandAvgSignals(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter}).flex = fc(:,:,1);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter}).ext = fc(:,:,2);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter}).rest = fc(:,:,3);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter}).flex_trials = fc_trials(:,idx_flex);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter}).ext_trials = fc_trials(:,idx_ext);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).(signal_label{signal_iter}).rest_trials = fc_trials(:,idx_rest);
        end
    end
end
end
%% Helper Function

function [idx_flex, idx_ext, idx_rest] = task_idx(labels)
idx_flex = find(labels == 1);
idx_ext = find(labels == 2);
idx_rest = find(labels == 3);


end

function sessionData = getSession(trialData)
fld = fieldnames(trialData);
sessionData = struct; % pre-allocation
% loop through subjects and sessions and then concatenate runs in sessions
for sub=1:length(trialData)
    for sess=1:length(fld)
        sessionData(sub).(fld{sess}) = makeSession(trialData(sub).(fld{sess}));
    end
end
    
    
end
function s = makeSession(x) % function to concatenate all runs in a session

myVars = fieldnames(x);
for i=1:length(myVars)
    s.(myVars{i}) = vertcat(x.(myVars{i}));   % read/concatenate 
end
 
end

function [fc1,fc_vec] = fc_lag(idx_flex, idx_ext, idx_rest,signal,channelSelect)
num_connects = (length(channelSelect)*(length(channelSelect)-1))/2;
fc_vec = zeros(num_connects,size(signal,1));
R = zeros(length(channelSelect));
% tic
for k = 1: size(signal,1)
%     tic
    for j=1:length(channelSelect)
        
        for i = 1:length(channelSelect)
            R(i,j) = laggedCoherence(signal(k,:,channelSelect(i)),signal(k,:,channelSelect(j)));
        end
    end
    R(isnan(R))=0;
    hold = R+abs(R);
    idx = (find(~hold==0));
    hold = hold(idx);
    fc_vec(:,k) = hold;
%     toc
%     disp('Trial finished')
%     disp(k/size(signal,1))
end
% toc
% disp('Time to finish one session of lagged coherence signal')
fc1 = zeros(num_connects,2,3);
fc1(:,:,1) = [mean(fc_vec(:,idx_flex),2) std(fc_vec(:,idx_flex),0,2)];
fc1(:,:,2) = [mean(fc_vec(:,idx_ext),2) std(fc_vec(:,idx_ext),0,2)];
fc1(:,:,3) = [mean(fc_vec(:,idx_rest),2) std(fc_vec(:,idx_rest),0,2)];
end


