function plotting_topos(featureStruct,chanlocs,window,signal_labels,Fs,num_channels)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


[subjects,sessions,task] = inspectfeatureStruct(featureStruct); % check if ERD_data or grandAvgSignals
fig = 1;
task_session_string = {'Flex','Ext','Rest','Flex','Ext','Rest'};
count =1;

for sub_iter=1:subjects % number of subjects
    for m=1:length(signal_labels)
            for t=1:length(task)
                for sess_iter=1:length(sessions)
                [topo_window_cell, idx_topo_times] = getTopoWindow(featureStruct(sub_iter)...
                    .(sessions{sess_iter}).(task{t}).(signal_labels{m})(:,:)...
                    ,window,Fs,num_channels); % get the topo window in a cell array
%                 signal = featureStruct(sub_iter).(sessions{sess_iter})...
%                     .(task{t}).(signal_labels{m})(:,1:length(chanlocs));
                figure(count)
                set(gcf,'Position',[0 0 800 720]);
                time_window_plot = idx_topo_times/Fs;
                for uu=1:length(idx_topo_times)-1
                    topowindow = cell2mat(topo_window_cell(uu,:));
                    plotting_averagetimepoints(topowindow,idx_topo_times,uu,chanlocs,signal_labels{m})
                    title([{strcat("Subject:",num2str(sub_iter)," S:",num2str(sess_iter)...
                        ," ",task_session_string{t}," ")},...
                        {strcat(string(signal_labels{m})," ",num2str(time_window_plot(uu))...
                        ," - ",num2str(time_window_plot(uu+1))," seconds")}],'Interpreter','none')
                end
                figure_title_str = strcat("Graphs/sub",num2str(sub_iter),"_session",num2str(sess_iter)...
                    ,"_",string(task{t}),"_",string(signal_labels{m}),".png");
                saveas(gcf,figure_title_str)
                count = count +1;
            end
        end
    end
end
end

%% Helper functions

function [c,idx] = getTopoWindow(signal,window,Fs,iter)
for ii= 1:iter
    v = signal(:,ii);
    b = floor(window*Fs); % block size
    n= numel(v);
    idx = 0:b:n;
    c(:,ii) =   mat2cell(v,diff([0:b:n-1,n]));
end

end
function plotting_averagetimepoints(topowindow,idx,uu,chanlocs,band)
sub_plot_len =  round(length(idx)/2);
subplot(sub_plot_len,2,uu,'align')
mu = mean(mean(topowindow));
sigma = std(mean(topowindow));
std_limits = [round(mu-2*sigma) round(mu+2*sigma)];
set_abs_limits = [-50 50];
topoplot(mean(topowindow),chanlocs,'maplimits',set_abs_limits,'emsize',10);
colorbar('Ticks',set_abs_limits(1):10:set_abs_limits(2))
format bank
text(-1.5,0,['mean ',num2str(mu,'%.2f')],'FontSize',10)
text(-1.5,-0.25,['std ',num2str(sigma,'%.2f')],'FontSize',10)
axis('square')                 
end

function [subjects, session, task] = inspectfeatureStruct(featureStruct)

subjects = length(featureStruct); % number of subjects
session = fieldnames(featureStruct); % number of sessions ie. pre and post
if length(session) > 2
    session = session(end-1:end);
    task = {'flex','ext','rest'};
else
    task = fieldnames(featureStruct(1).(session{1}));
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This one kind of works.
% function topo_in_time(signal,Fs,task,sub_iter,sess_iter,t,signal_labels,m,chanlocs,count)
% figure(100+m)
% for i=size(signal,1)-1:size(signal,1)
%     subplot(3,2,count)
%     topoplot(signal(i,:),chanlocs)
%     title(['Subject',num2str(sub_iter),' S',...
%         num2str(sess_iter),' ',task{t},' ',signal_labels{m}])
%     if i == size(signal,1)-1
%         set(gca,'nextplot','replacechildren')
%         w = VideoWriter('test.avi');
%         w.FrameRate = 2*Fs;
%         open(w);
%     end
%     frame = getframe(gcf);
%     writeVideo(w,frame);
% end
% close(w)
% 
% end