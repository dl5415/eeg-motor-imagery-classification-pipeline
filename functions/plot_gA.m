function plot_gA(featurestruct,signal_labels,channel_num,time,Marker)
%PLOT_G_AVG Summary of this function goes here
%   Detailed explanation goes here
Colors = {'r', 'y', 'b', 'g'};
labels = {'Alpha 8-11 Hz','Beta 12-30 Hz'};
sessions = fieldnames(featurestruct(1));
fig = 1;
for i=1:length(featurestruct)
    task = fieldnames(featurestruct(i).(sessions{1}));
    for k=1:length(task)
        for m=1:length(signal_labels)
%             if m == 2
%                 ymax = 3*mean(dev);
%                 axis([time(1) time(end) 0 ymax])
%             end
            figure(fig)
            set(gcf,'Position',[200 100 800 600])
            subplot(2,1,1)
            [signal,dev] = choose_signal(featurestruct(i).(sessions{1})...
                .(task{k}).(signal_labels{m}),channel_num(i,:));
            plot_std_dev(time,signal,dev)
            title("Pre Stimulation")
            ylabel('Grand Avg Power (uV)^2') % change this to be feature value
            axis([time(1) time(end) 0 4e-3])
            if m == 2
                axis([time(1) time(end) 0 5e-4])
            end
            for p = 1:length(Marker.timestamp)
                xline(time(Marker.timestamp(p)), Colors{p}, 'LineWidth', 3, 'DisplayName', Marker.stamp_name{p});
            end
            grid on
            grid minor
            xlabel('Trial Time (s)')
            subplot(2,1,2)
            plot_std_dev(time,signal,dev)
            title('Post Stimulation')
            ylabel('Grand Avg Power (uV)^2') % change this to be feature value
             axis([time(1) time(end) 0 4e-3])
            if m == 2
                axis([time(1) time(end) 0 6e-4])
            end
            for p = 1:length(Marker.timestamp)
                xline(time(Marker.timestamp(p)), Colors{p}, 'LineWidth', 3, 'DisplayName', Marker.stamp_name{p});
            end
            grid on
            grid minor
            xlabel('Trial Time (s)')
            sgtitle(strcat("Subject ",num2str(i), " Task:",task{k}...
                ," ",labels{m}," Grand Avg MI Cluster"))
            figure_title_str = strcat("Graphs/sub",num2str(i),"_",string(task{k}),...
                    "_",string(signal_labels{m}),".png");
                saveas(gcf,figure_title_str)
            fig = fig+1;
        end
    end
end
end


%% Helper function
% function used to plot alpha and beta power on the same grand average to
% see ERD/ERS modulation. If alpha and beta power are not the only signal
% labels desired then the function will plot each signal type in separate
% figures
% special plotting is necessary to visualize the alpha vs beta bands this
% switch is done through the boolean spec.

function [signal2plot,dev] = choose_signal(signal,channel_select)
    % standard deviations appended in block after signal values, using
    % shift to get the standard devatiation values
    signal2plot = mean(signal(:,channel_select),2);
    shift = size(signal,2)/2; 
    dev = mean(signal(:,channel_select+shift),2);
    
end

function plot_std_dev(time,signal,dev)
% if (signal) 
%     plot(time,signal(:,1))
%     plot(time,signal+dev)
%     plot(time,signal-dev)
% else
    plot(time,signal(:,1),'Color','k')
    hold on
    plot(time,signal+dev,'Color','k','LineStyle',':')
    plot(time,signal-dev,'Color','k','LineStyle',':')
    lgd = legend('signal','std err','east');
    lgd.Location = 'bestoutside';
% end
end

