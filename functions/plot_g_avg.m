function [a] = plot_g_avg(featurestruct,signal_labels,channel_select,channel,time)
%PLOT_G_AVG Summary of this function goes here
%   Detailed explanation goes here

sessions = fieldnames(featurestruct(1));
fig = 1;
for i=2:length(featurestruct)
    for j=1:length(sessions)
        task = fieldnames(featurestruct(i).(sessions{j}));
        for n=1:length(channel_select)
            count = 1;
            for k=1:length(task)
                for m=1:length(signal_labels)
                    figure(fig)
                    [signal,dev] = choose_signal(featurestruct(i).(sessions{j})...
                        .(task{k}),signal_labels,channel_select(n),m);
                    subplot(length(task),length(signal_labels),count)
                    % plot_std_dev(time,signal,dev)
                    plot(time,signal);
                    title(['Subject ',num2str(i), ' ',sessions{j},' stimulus ',...
                        signal_labels{m},' ',task{k},' ',channel{n}])
                    legend(signal_labels{m})
                    ylabel('Grand Avg Power (uV)^2') % change this to be feature value
                    xline(0,'--r','Trial Queue','HandleVisibility','off')
                    grid on
                    grid minor
                    xlabel('Trial Time (s)')
                    count = count +1;
                end
            end
            fig = fig+1;
        end
    end
end
a =1;
end


%% Helper function
% function used to plot alpha and beta power on the same grand average to
% see ERD/ERS modulation. If alpha and beta power are not the only signal
% labels desired then the function will plot each signal type in separate
% figures
% special plotting is necessary to visualize the alpha vs beta bands this
% switch is done through the boolean spec.

function [signal2plot,dev] = choose_signal(signal,signal_labels,channel_select,m)
    % standard deviations appended in block after signal values, using
    % shift to get the standard devatiation values
    signal2plot = signal.(signal_labels{m})(:,channel_select);
    shift = size(signal.(signal_labels{m}),2)/2; 
    dev = signal.(signal_labels{m})(:,channel_select+shift);
    
end

function a = plot_std_dev(time,signal,dev)
% if (signal) 
%     plot(time,signal(:,1))
%     plot(time,signal+dev)
%     plot(time,signal-dev)
% else
    plot(time,signal(:,1))
    hold on
    plot(time,signal+dev,'--r')
    plot(time,signal-dev,'--r')
    legend('signal','std_dev')
    a=1;
% end
end

