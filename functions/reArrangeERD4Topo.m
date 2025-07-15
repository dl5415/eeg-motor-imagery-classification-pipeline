function [featStruct] = reArrangeERD4Topo(ERD_data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
subjects = length(ERD_data);
task = {'flex', 'ext','rest'};
sz = size(ERD_data(1).pre.(task{1}).ERD_alpha); % size of the signal, (#timepoints x # channels)
signal_labels = fieldnames(ERD_data(1).pre.(task{1}));
tmp = fieldnames(ERD_data);
sessions = tmp(end-1:end); % getting pre and post session field names out of ERD_data
topo_str = {'topo1','topo2','topo3','topo4','topo5','topo6'};
featStruct = topoStruct(subjects,topo_str,signal_labels,sz);
for s=1:subjects
    for m=1:length(signal_labels)
        count =1;
        for ss=1:length(sessions)
            for t=1:length(task)
                signal = ERD_data(s).(sessions{ss}).(task{t}).(signal_labels{m});
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