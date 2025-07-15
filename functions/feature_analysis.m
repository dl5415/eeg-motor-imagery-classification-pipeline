%% Feature analysis function

function analysis = feature_analysis(selected, contra_channels, ipsi_channels, alpha, beta, cue_times, task_times)
    analysis = struct;
    sessions = {'pre', 'post'};
    for s = 1:2
        for ses = 1:2
            labels = selected(s).(sessions{ses})(1).labels;
            k = length(labels);
            analysis(s).(sessions{ses}).labels = labels;
            
            contra_counts = get_counts(labels, 'C:', contra_channels(s).labels);
            ipsi_counts = get_counts(labels, 'C:', ipsi_channels(s).labels);
            alpha_counts = get_counts(labels, 'F:', alpha);
            beta_counts = get_counts(labels, 'F:', beta);
            cue_counts = get_counts(labels, 'T:', cue_times);
            task_counts = get_counts(labels, 'T:', task_times);
            
            analysis(s).(sessions{ses}).contra_counts = contra_counts;
            analysis(s).(sessions{ses}).ipsi_counts = ipsi_counts;
            analysis(s).(sessions{ses}).alpha_counts = alpha_counts;
            analysis(s).(sessions{ses}).beta_counts = beta_counts;
            analysis(s).(sessions{ses}).cue_counts = cue_counts;
            analysis(s).(sessions{ses}).task_counts = task_counts;
            
            analysis(s).(sessions{ses}).contra_perc = 100*sum(contra_counts)/k;
            analysis(s).(sessions{ses}).ipsi_perc = 100*sum(ipsi_counts)/k;
            analysis(s).(sessions{ses}).alpha_perc = 100*sum(alpha_counts)/k;
            analysis(s).(sessions{ses}).beta_perc = 100*sum(beta_counts)/k;
            analysis(s).(sessions{ses}).cue_perc = 100*sum(cue_counts)/k;
            analysis(s).(sessions{ses}).task_perc = 100*sum(task_counts)/k;
        end
    end
end

%% Helper functions

function counts = get_counts(features, type, labels)
    counts = zeros(1, length(labels));
    for i = 1:length(features)
        for j = 1:length(labels)
            look_for = strcat(type, labels{j});
            if contains(features{i}, look_for)
                counts(j) = counts(j) + 1;
            end
        end
    end
end