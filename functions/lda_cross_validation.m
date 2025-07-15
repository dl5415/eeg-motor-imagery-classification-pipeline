%% Cross validation function

function CV = lda_cross_validation(selected)
    sessions = {'pre', 'post'};
    target_labels = {'Flex', 'Ext', 'Rest'};
    CV = struct;
    for s = 1:2 % 2 subjects
        for ses = 1:2 % 2 sessions      
            acc_avg = 0;
            for k = 1:2 % run_wise
                %Validation set
                test_data = selected(s).(sessions{ses})(k).values;
                test_data_targets = selected(s).(sessions{ses})(k).targets;
                %Train set
                train_data = selected(s).(sessions{ses})(rem(k,2)+1).values;
                train_data_targets = selected(s).(sessions{ses})(rem(k,2)+1).targets;
                %Classify: multi-class lda
                model = fitcdiscr(train_data, train_data_targets, 'DiscrimType', 'diagLinear');
                outputs = predict(model, test_data);
                [c, cm, ~, ~] = confusion(fix_targets(test_data_targets), fix_targets(outputs));       
                acc_avg = acc_avg + 1 - c;
                %Store performance
                CV(s).(sessions{ses}).folds(k).acc = 1 - c;
                CV(s).(sessions{ses}).folds(k).cm = cm;
                CV(s).(sessions{ses}).folds(k).model = model;
                CV(s).(sessions{ses}).folds(k).true = categorical_targets(test_data_targets, target_labels);
                CV(s).(sessions{ses}).folds(k).predicted = categorical_targets(outputs, target_labels);
            end  
            CV(s).(sessions{ses}).acc_avg = acc_avg/2;
            disp(acc_avg/2)
        end
    end
end