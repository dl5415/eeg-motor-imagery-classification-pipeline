%% Function to select features

function selected = select_features_fisher(features, run_ranges, k)    
    selected = struct;
    sessions = {'pre', 'post'};
    % for every subject
    for s = 1:2
        % for every session
        for ses = 1:length(sessions)
            values = features.values(s).(sessions{ses});
            labels = features.labels(s).sig(1,:);
            targets = features.trials(s).(strcat(sessions{ses},'_label'));
           
            [out] = fsFisher(values, targets);
            all_selected_inds = out.fList(1:k);
            % save selected indices, values, and labels as well as target
            % classes for classification for each run
            for r = 1:2
                run_range = run_ranges(s,ses,r).vals;
                selected(s).(sessions{ses})(r).indices = all_selected_inds;
                selected(s).(sessions{ses})(r).values = values(run_range,all_selected_inds);
                selected(s).(sessions{ses})(r).labels = labels(all_selected_inds);
                selected(s).(sessions{ses})(r).targets = targets(run_range);
            end
        end
    end
end
