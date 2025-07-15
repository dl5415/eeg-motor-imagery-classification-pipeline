%% Function to plot condensed topos for report

function condensed_topos(ERD_data, chanlocs, start_time, duration, limits, fs, file_type)
    % hard coded these because lazy
    subjects = {'sub1', 'sub2'};
    subject_labels = {'Subject 1', 'Subject 2'};
    sessions = {'pre', 'post'};
    session_labels = {'Pre TESS', 'Post TESS'};
    tasks = {'flex', 'ext', 'rest'};
    task_labels = {'Flex', 'Ext', 'Rest'};
    bands = {'ERD_alpha', 'ERD_beta'};
    band_labels = {'Alpha Band', 'Beta Band'};
    % set to 3 to include rest
    num_tasks = 2;
    
    for s = 1:2
        fig = figure('units', 'normalized', 'Position', [0,0,0.25,1]);
        p = 1;
        for t = 1:num_tasks
            for b = 1:2
                for se = 1:2
                    avg = get_avg(ERD_data(s).(sessions{se}).(tasks{t}).(bands{b}), start_time, duration, fs);
                    subplot_title = strcat(session_labels{se}, {' '}, task_labels{t}, {' '}, band_labels{b});
                    subplot(num_tasks*2, 2, p);
                    plot_topo(avg, chanlocs, limits, subplot_title)
                    p = p + 1;
                end
            end
        end
        span_label = strcat(num2str(start_time - 2), '-', num2str(start_time + duration - 2));
        big_title = strcat({' Avg ERD for '}, span_label, {' sec After Task Onset'});
        sgtitle(strcat(subject_labels{s}, big_title), 'FontSize', 10);
        spacing = (limits(2) - limits(1))/10;
        colorbar('Ticks', limits(1):spacing:limits(2), 'TickDirection', 'out', 'Location', 'south', 'Position', [0.1 0.075 0.85 0.02])
        exportgraphics(fig, strcat('Graphs\', subjects{s}, '_ERD_topo', file_type));
    end
end

%% Helper functions

function plot_topo(signal, chanlocs, limits, subplot_title)
    topoplot(signal, chanlocs, 'maplimits', limits, 'emsize', 10);
    title(subplot_title, 'FontSize', 7);
end

function avg = get_avg(signal, start_time, duration, fs)
    start_i = start_time*fs + 1;
    end_i = start_i + duration*fs;
    avg = mean(signal(start_i:end_i,:));
end
