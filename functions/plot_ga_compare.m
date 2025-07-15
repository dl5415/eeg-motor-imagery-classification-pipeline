function val = plot_ga_compare(featurestruct,signal_labels,channel_select,channel,time)
    sessions = fieldnames(featurestruct(1));
    fig = 1;
    for i=1:length(featurestruct)
        for j=1:length(sessions)
            task = fieldnames(featurestruct(i).(sessions{j}));
            for n=1:length(channel_select)
                for k=1:length(task)
                        figure(fig)
                        [signal,dev] = choose_signal(featurestruct(i).(sessions{j})...
                            .(task{k}),signal_labels,channel_select(n));
                        subplot(length(task),1,k)
                        % plot_std_dev(time,signal,dev)
                        plot(time,signal);
                        title(['Subject ',num2str(i), ' ',sessions{j},' stimulus ',...
                            signal_labels{1},' vs ',signal_labels{2},' ',task{k},' ',channel{n}])
                        legend(signal_labels{1},signal_labels{2})
                        ylabel('ZScore Grand Avg Power (uV)^2') % change this to be feature value
                        xline(0,'--r','Trial Queue','HandleVisibility','off')
                        grid on
                        grid minor
                        xlabel('Trial Time (s)')
                end
                fig = fig+1;
            end
        end
    end
    val = 1;
end
%% Helper functions
% function to choose what signal we want to plot
function [signal2plot,dev] = choose_signal(signal,signal_labels,channel_select)
    % standard deviations appended in block after signal values, using
    % shift to get the standard devatiation values
    shift = size(signal.(signal_labels{1}),2)/2; 
    % concatenating both signals/features in one array
    signal2plot = [zscore(signal.(signal_labels{1})(:,channel_select))...
        zscore(signal.(signal_labels{2})(:,channel_select))]; 
    dev = [signal.(signal_labels{1})(:,channel_select+shift)...
        signal.(signal_labels{2})(:,channel_select+shift)];
end

% function to plot standard deviation of signal/feature values
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