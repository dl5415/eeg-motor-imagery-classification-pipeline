function  topo_feat_plot(topoStruct,chanlocs,window,Fs,num_channels,topo_limits)
%TOPO_FEAT_PLOT Summary of this function goes here
%   Detailed explanation goes here
subjects = length(topoStruct);
signal_labels = fieldnames(topoStruct);
topo_str = fieldnames(topoStruct(1).(signal_labels{1}));
task_session_string = {'Flex S1','Ext S1','Rest S1','Flex S2','Ext S2','Rest S2'};
fig = 1;
for s=1:subjects
    for m=1:length(signal_labels)
        figure(fig)
        for count=1:length(topo_str)
            subplot(2,3,count)
            [topo_window_cell, idx_topo_times] = getTopoWindow(topoStruct(s)...
                .(signal_labels{m}).(topo_str{count})...
                ,window(1),Fs,num_channels);
            [time_bounds] = [idx_topo_times(window(2))/Fs,idx_topo_times(window(2)+1)/Fs];
            topowindow = cell2mat(topo_window_cell(window(2),:));
%             topoplot(mean(topowindow),chanlocs,...
%                 'maplimits',topo_limits)
            topoplot(mean(topowindow),chanlocs);
            title([{strcat("Subject: ",num2str(s)," ",task_session_string{count})}...
                {strcat(signal_labels{m}," ", num2str(time_bounds(1)), " - ",...
                num2str(time_bounds(2))," seconds")}])
%             colorbar('Ticks',topo_limits(1):1:topo_limits(2))
            colorbar
        end
        fig = fig+1;
    end
end

end
%%
function [c,idx] = getTopoWindow(signal,window,Fs,iter)
for ii= 1:iter
    v = signal(:,ii);
    b = floor(window*Fs); % block size
    n= numel(v);
    idx = 0:b:n;
    c(:,ii) =   mat2cell(v,diff([0:b:n-1,n]));
end
end