%% Function to select features

function selected = select_features_md(features, run_ranges, k)    
    selected = struct;
    sessions = {'pre', 'post'};
    % for every subject
    for s = 1:2
        % for every session
        for ses = 1:length(sessions)
            values = features.values(s).(sessions{ses});
            labels = features.labels(s).sig(1,:);
            targets = features.trials(s).(strcat(sessions{ses},'_label'));
            all_selected_inds = [];
            % select best features for separating each class from all other
            % classes
            for c = 1:3
                selected_inds = [];
                md_vals = [];
                % find k features for each class
                for i = 1:k
                    max_md = 0;
                    arg_max_md = 0;
                    % consider md for adding each feature to current
                    % feature pool, looking for maximum
                    for f = 1:length(labels)
                        % only consider features not already selected
                        if ~ismember(f, selected_inds)
                            feature_inds = [selected_inds, f];
                            values_c = values(targets == c,feature_inds);
                            values_notc = values(targets ~= c,feature_inds);
                            % take mean across all md values for
                            % observations of class c
                            md = my_md(values_c, values_notc);
                            % finding max md and feature that resulted in
                            % it
                            if md > max_md
                                max_md = md;
                                arg_max_md = f;
                            end
                        end
                    end
                    % record selected feature and resulting md
                    selected_inds(end+1) = arg_max_md; %#ok<*AGROW>
                    md_vals(end+1) = max_md;
                end
                % union selected indices for this class with selected
                % indices from all other classes
                all_selected_inds = union(all_selected_inds, selected_inds);
                % save selected indices and md values for each class for
                % later reference
                for r = 1:2
                    selected(s).(sessions{ses})(r).class_details(c).selected_inds = selected_inds;
                    selected(s).(sessions{ses})(r).class_details(c).md_vals = md_vals;
                end
            end
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

%% Helper functions

function md = my_md(X, Y)
    mux = mean(X, 1);
    muy = mean(Y, 1);
    sigma = cov(vertcat(X, Y));
    md = (mux - muy)*inv(sigma)*(mux - muy).'; %#ok<MINV>
end
