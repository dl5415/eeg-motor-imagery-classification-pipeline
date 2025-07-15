function [featStruct] = reArrangeGA4Topo(featureStruct,signal_labels)
%REARRANGEGA4TOPO Summary of this function goes here
%   Detailed explanation goes here
channels = 32;
subjects = length(featureStruct); % number of subjects
sessions = fieldnames(featureStruct); % number of sessions ie. pre and post
task = fieldnames(featureStruct(1).(sessions{1}));
topo_str = {'topo1','topo2','topo3','topo4','topo5','topo6'};
sz = size(featureStruct(1).(sessions{1}).(task{1}).(signal_labels{1})(:,1:channels));
featStruct = topoStruct(subjects,topo_str,signal_labels,sz);
for s=1:subjects
    for m=1:length(signal_labels)
        count =1;
        for ss=1:length(sessions)
            for t=1:length(task)
                signal = featureStruct(s).(sessions{ss}).(task{t}).(signal_labels{m})(:,1:channels);
                featStruct(s).(signal_labels{m}).(topo_str{count}) = signal; 
                count = count + 1;
            end
        end
    end
end

end
%% Helper Function
function featStruct =  topoStruct(subjects,topo_str,signal_labels,sz)
for m=1:length(signal_labels)
    for count=1:length(topo_str)
        if m ==1 && count == 1
              featStruct1 = struct(signal_labels{m},struct(topo_str{count},zeros(sz)));
        else
            featStruct1.(signal_labels{m}).(topo_str{count}) = zeros(sz);
        end
    end
    featStruct = repmat(featStruct1,1,subjects);
end
    
end