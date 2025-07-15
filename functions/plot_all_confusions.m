%% Plot confusion function

function plot_all_confusions(CV, file_type)
    subjects = {'sub1', 'sub2'};
    sessions = {'pre', 'post'};
    subject_labels = {'Subject 1', 'Subject 2'};
    session_labels = {' Pre TESS', ' Post TESS'};
    for s = 1:2
        for ses = 1:2
            all_true = [];
            all_predicted = [];
            for k = 1:2
                all_true = horzcat(all_true, CV(s).(sessions{ses}).folds(k).true); %#ok<*AGROW>
                all_predicted = horzcat(all_predicted, CV(s).(sessions{ses}).folds(k).predicted);
            end
            cm_title = strcat(subject_labels{s}, session_labels{ses});
            plotconfusion(all_true, all_predicted, cm_title);
            exportgraphics(gca, strcat('Graphs\', subjects{s}, '_', sessions{ses}, '_CM', file_type));
        end
    end
end
