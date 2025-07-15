function  FC_cluster(FC,chan_labels,idx,signal_labels,channels)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
chan_pairs = strcat(meshgrid(strcat(chan_labels," ")),meshgrid(chan_labels)');
chan_pairs_vec = chan_pairs(idx);
subjects = length(FC); % number of subjects
sessions = fieldnames(FC); % number of sessions ie. pre and post
num_trials = 25;
labels = {'Alpha 8-11 Hz','Beta 12-30 Hz'};
fig = 1;
for s = 1:subjects
        for sl = 1:length(signal_labels)
            figure(fig)
            set(gcf,'Position',[200 100 800 600])
            [mu_flex1,SEM_flex1] = computeMeanSEM(FC(s).(sessions{1}).(signal_labels{sl})...
                .flex_trials(channels(s,:),:));
            [mu_flex2,SEM_flex2] = computeMeanSEM(FC(s).(sessions{2}).(signal_labels{sl})...
                .flex_trials(channels(s,:),:));
            [mu_ext1,SEM_ext1] = computeMeanSEM(FC(s).(sessions{1}).(signal_labels{sl})...
                .ext_trials(channels(s,:),:));
            [mu_ext2,SEM_ext2] = computeMeanSEM(FC(s).(sessions{2}).(signal_labels{sl})...
                .ext_trials(channels(s,:),:));
            subplot(2,1,1)
            flex_vals = [mu_flex1 mu_flex2];
            flex_SEM = [SEM_flex1 SEM_flex2];
            hbar1 = bar(flex_vals);
            hAx=gca;                       % handle to the axes object
            hAx.XTickLabel=categorical({'Session 1 (Pre)','Session 2 (Post)'});  % label by categories
            %     hBar.CData(2,:) = [0 0 0];
            hold on
            barLoc = get(hbar1,'XData').'+[hbar1.XOffset];  % compute bar locations
            hEB = errorbar(barLoc,flex_vals,flex_SEM,'.');  % add the errorbar
            title("Flexion")
            subplot(2,1,2)
            ext_vals = [mu_ext1 mu_ext2];
            ext_SEM = [SEM_ext1 SEM_ext2];
            hBar = bar(ext_vals);
            hAx=gca;                       % handle to the axes object
            hAx.XTickLabel=categorical({'Session 1 (Pre)','Session 2 (Post)'});  % label by categories
            %     hBar.CData(2,:) = [0 0 0];
            hold on
            barLoc = get(hBar,'XData').'+[hBar.XOffset];  % compute bar locations
            hEB = errorbar(barLoc,ext_vals,ext_SEM,'.');  % add the errorbar
            title("Extension")
            sgtitle(strcat("Subject ",num2str(s), " Functional Connectivity"...
            ," of MI Network in ",labels{sl}))
        figure_title_str = strcat("Graphs/sub",num2str(s)...
            ,"_FC","_",string(signal_labels{sl}),".png");
        saveas(gcf,figure_title_str)
        fig = fig +1;
        end
end
end
function [mu,SEM] = computeMeanSEM(signal)
    mu = mean(mean(signal));
    SEM = std(mean(signal))/sqrt(length(mean(signal)));
end