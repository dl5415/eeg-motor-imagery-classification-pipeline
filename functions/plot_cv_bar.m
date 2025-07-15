%% Plot CV Bar

function plot_cv_bar(CV, cv_title)
    sessions = {'pre', 'post'};
    subject_labels = {'Subject 1', 'Subject 2'};
    acc_vals = zeros(2, 2);
    for s = 1:2
        for ses = 1:2
            acc_vals(s,ses) = 100*CV(s).(sessions{ses}).acc_avg;
        end
    end
    
    subject_cats = categorical(subject_labels);
    subject_cats = reordercats(subject_cats, subject_labels);
    b = bar(subject_cats, acc_vals);
    hold on
    yline(33.3, 'k', 'LineWidth', 2, 'DisplayName', 'Chance');
    set(b, {'DisplayName'}, {'Pre TESS', 'Post TESS'}');
    legend('FontSize', 8, 'Location', 'northwest');
    ylabel('Accuracy [%]', 'fontweight', 'bold');
    ylim([0, 100]);
    title(cv_title, 'FontSize', 9);
    grid on; grid minor;
end
