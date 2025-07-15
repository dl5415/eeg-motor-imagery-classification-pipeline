function  FC_analysis(FC,chan_labels,idx,signal_labels)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
chan_pairs = strcat(meshgrid(strcat(chan_labels," ")),meshgrid(chan_labels)');
chan_pairs_vec = chan_pairs(idx);
subjects = length(FC); % number of subjects
sessions = fieldnames(FC); % number of sessions ie. pre and post
num_trials = 25;
for s = 1:subjects
    for ss = 1:length(sessions)
        for sl = 1:length(signal_labels)
            [h_flex, ~] = ttest(FC(s).(sessions{ss}).(signal_labels{sl})...
                .flex_trials(:,:)',mean(mean(FC(s).(sessions{ss}).(signal_labels{sl})...
                .flex_trials(:,:)')),'Alpha',0.05,'Tail','right');
            [h_ext, ~] = ttest(FC(s).(sessions{ss}).(signal_labels{sl})...
                .ext_trials(:,:)',mean(mean(FC(s).(sessions{ss}).(signal_labels{sl})...
                .ext_trials(:,:)')),'Alpha',0.05,'Tail','right');
            vals_flex = FC(s).(sessions{ss}).(signal_labels{sl})...
                .flex(1:end,:);
            vals_ext = FC(s).(sessions{ss}).(signal_labels{sl})...
                .ext(1:end,:);
            if ~isempty(vals_flex(logical(h_flex)))
                mean_val = mean(mean(FC(s).(sessions{ss}).(signal_labels{sl})...
                .flex_trials(:,:)'));
                std_val = std(mean(FC(s).(sessions{ss}).(signal_labels{sl})...
                .flex_trials(:,:)'));
                X = [categorical(chan_pairs_vec(logical(h_flex)))', categorical({'mean'})];
                Y = [vals_flex(logical(h_flex),1)', mean_val];
                Y_std = [vals_flex(logical(h_flex),2)', std_val]/sqrt(num_trials);
                figure()
                bar(X,Y)
                hold on
                er = errorbar(X,Y,-Y_std,Y_std);
                er.Color = [0 0 0];
                er.LineStyle = 'none';
                title([{strcat("Subject ",num2str(s)," ",sessions{ss}," stimulation")}...
                    ,{strcat(" FC Siginificant Channels of Flex in ",signal_labels{sl})}])
                ylabel('FC (lagged coherence)')
                xlabel('Channel Pairs')
                figure_title_str = strcat("Graphs/sub",num2str(s),"_Session",num2str(ss),...
                    "_FC_flex","_",string(signal_labels{sl}),".png");
                    saveas(gcf,figure_title_str)
            end
            if ~isempty(vals_ext(logical(h_ext)))
                mean_val = mean(mean(FC(s).(sessions{ss}).(signal_labels{sl})...
                .ext_trials(:,:)'));
                std_val = std(mean(FC(s).(sessions{ss}).(signal_labels{sl})...
                .ext_trials(:,:)'));
                X = [categorical(chan_pairs_vec(logical(h_ext)))', categorical({'mean'})];
                Y = [vals_ext(logical(h_ext),1)', mean_val];
                Y_std = [vals_ext(logical(h_ext),2)', std_val]/sqrt(num_trials);
                figure()
                bar(X,Y)
                hold on
                er = errorbar(X,Y,-Y_std,Y_std);
                er.Color = [0 0 0];
                er.LineStyle = 'none';
                title([{strcat("Subject ",num2str(s)," ",sessions{ss}," stimulation")}...
                    ,{strcat(" FC Siginificant Channels of Ext in ",signal_labels{sl})}])
                xlabel('Channel Pairs')
                ylabel('FC (lagged coherence)')
                figure_title_str = strcat("Graphs/sub",num2str(s),"_Session",num2str(ss),...
                    "_FC_Ext","_",string(signal_labels{sl}),".png");
                    saveas(gcf,figure_title_str)
                hold off
            end
            if ss == 1
                [h_flex, ~] = ttest2(FC(s).pre.(signal_labels{sl}).flex_trials(:,:)'...
                    ,FC(s).post.(signal_labels{sl}).flex_trials(:,:)');
                [h_ext, ~] = ttest2(FC(s).pre.(signal_labels{sl}).ext_trials(:,:)'...
                    ,FC(s).post.(signal_labels{sl}).ext_trials(:,:)');
                vals_flex_pre = FC(s).pre.(signal_labels{sl})...
                    .flex(1:end,:);
                vals_flex_post = FC(s).post.(signal_labels{sl})...
                    .flex(1:end,:);
                vals_ext_pre = FC(s).pre.(signal_labels{sl})...
                    .ext(1:end,:);
                vals_ext_post = FC(s).post.(signal_labels{sl})...
                    .ext(1:end,:);
                if logical(sum(h_flex))
                    plot_ttest2_results(vals_flex_pre, vals_flex_post,h_flex,chan_pairs_vec,num_trials)
                    title([{strcat("Subject ",num2str(s)," Flex Condition")}...
                    ,{strcat(" FC Siginificant Change after stimulation ",signal_labels{sl})}])
                    xlabel('Channel Pairs')
                    ylabel('FC (lagged coherence)')
                    figure_title_str = strcat("Graphs/sub",num2str(s)...
                    ,"_FC_flex","_",string(signal_labels{sl}),".png");
                    saveas(gcf,figure_title_str)
                end
                if logical(sum(h_ext))
                    plot_ttest2_results(vals_ext_pre, vals_ext_post,h_ext,chan_pairs_vec,num_trials)
                     title([{strcat("Subject ",num2str(s)," Ext Condition")}...
                    ,{strcat(" FC Siginificant Change after stimulation ",signal_labels{sl})}])
                    xlabel('Channel Pairs')
                    ylabel('FC (lagged coherence)')
                    figure_title_str = strcat("Graphs/sub",num2str(s)...
                    ,"_FC_ext","_",string(signal_labels{sl}),".png");
                    saveas(gcf,figure_title_str)
                end
            end
        end
    end
end

end

function plot_ttest2_results(vals_pre,vals_post, h_,chan_pairs_vec,num_trials)
X = 1:length(chan_pairs_vec(logical(h_)));
Y = [vals_pre(logical(h_),1), vals_post(logical(h_),1)];
Y_std = [vals_pre(logical(h_),2), vals_post(logical(h_),2)]/sqrt(num_trials);
figure()
if length(X) == 1 % one significant value
    hBar = bar(Y);
    hAx=gca;                       % handle to the axes object
    hAx.XTickLabel=categorical({'Session 1 (Pre)','Session 2 (Post)'});  % label by categories
%     hBar.CData(2,:) = [0 0 0];
    hold on
    barLoc = get(hBar,'XData').'+[hBar.XOffset];  % compute bar locations
    hEB = errorbar(barLoc,Y,Y_std,'.');  % add the errorbar
    legend(chan_pairs_vec(logical(h_)))
else
    hBar = bar(X,Y);
    hAx=gca;                       % handle to the axes object
    set(hAx,'XTick',1:length(chan_pairs_vec(logical(h_))));
    hAx.XTickLabel=categorical(chan_pairs_vec(logical(h_)));  % label by categories
    xtickangle(45);
    hold on
    barLoc = cell2mat(get(hBar,'XData')).'+[hBar.XOffset];  % compute bar locations
    hEB = errorbar(barLoc,Y,Y_std,'.');  % add the errorbar
    legend('pre','post')
end


end
