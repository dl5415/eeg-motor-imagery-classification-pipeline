function features = features_rem(features, Art_indx)
    features_fields = {'values', 'labels', 'trials'};
    features_subfields_pre = {'pre_eeg', 'pre_label'};
    features_subfields_post = {'post_eeg', 'post_label'};
    task = 2; %extension
    %subject 1 pre
    indx = find(features.trials(1).pre_label == task);
    for i = 1:length(features_fields)
        if isequal(features_fields{i}, 'trials')
            for k = 1:length(features_subfields_pre)
                %Subject 1 pre
                features.(features_fields{i})(1).(features_subfields_pre{k})(indx(Art_indx.sub1.ext_pre_indx),:,:) = [];
            end
        elseif isequal(features_fields{i}, 'values')
            %Subject 1 pre
            features.(features_fields{i})(1).pre(indx(Art_indx.sub1.ext_pre_indx),:,:) = [];
        else
            %labels (features) -> not really needed, as each row is the same.
            features.(features_fields{i})(1).sig(indx(Art_indx.sub1.ext_pre_indx),:,:) = [];
            
        end
    end
    
    indx = find(features.trials(2).post_label == task);
    for i = 1:length(features_fields)
        if isequal(features_fields{i}, 'trials')
            for k = 1:length(features_subfields_post)
                %Subject 2 post
                features.(features_fields{i})(2).(features_subfields_post{k})(indx(Art_indx.sub2.ext_post_indx),:,:) = [];
            end
        elseif isequal(features_fields{i}, 'values')
            %Subject 2 post
            features.(features_fields{i})(2).post(indx(Art_indx.sub2.ext_post_indx),:,:) = [];
        else
            features.(features_fields{i})(2).sig(indx(Art_indx.sub2.ext_post_indx),:,:) = [];
        end
    end



end