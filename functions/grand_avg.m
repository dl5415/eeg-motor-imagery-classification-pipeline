function [grandAvgSignals] = grand_avg(trialData,channelSelect,signal_label)
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
            ga = g_avg_std(idx_flex, idx_ext, idx_rest,signal,channelSelect); 
            % bundle the g_avg values into subject,session, signal type
            % structure
            grandAvgSignals(sub_iter).(sessions{sess_iter}).flex.(signal_label{signal_iter}) = ga(:,:,1);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).ext.(signal_label{signal_iter}) = ga(:,:,2);
            grandAvgSignals(sub_iter).(sessions{sess_iter}).rest.(signal_label{signal_iter}) = ga(:,:,3);
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

function ga = g_avg_std(idx_flex, idx_ext, idx_rest,signal,channelSelect)
sz = size(squeeze(mean(signal(idx_flex,:,channelSelect))));
ga = zeros(sz(1),2*sz(2),3);
ga(:,:,1) = [squeeze(mean(signal(idx_flex,:,channelSelect))) squeeze(std(signal(idx_flex,:,channelSelect)))];
ga(:,:,2) = [squeeze(mean(signal(idx_ext,:,channelSelect))) squeeze(std(signal(idx_flex,:,channelSelect)))];
ga(:,:,3) = [squeeze(mean(signal(idx_rest,:,channelSelect))) squeeze(std(signal(idx_rest,:,channelSelect)))];
end
