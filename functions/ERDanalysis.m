function [ERD_subject, sig_h, sig_p, prepost_h, prepost_p] = ERDanalysis(ERD_data, channel, TrialOnset, Fs, channel_list, Art_indx)
    task = [{'Flexion','Extension','Rest'}];%labels 1,2,3
    chan_fields = {'sub1', 'sub2'};
    subfields = {'pre', 'post'};
    %Length of task period
    Task_time = 4 * Fs;
    subject = struct;
    for s = 1:2 %subjects
        for j = 1:length(task) %tasks
            pre_alpha = [];pre_beta = []; post_alpha = []; post_beta = [];
            for z = 1:length(channel.sub1)
                %Extract task 1 ERD, and compute their grand average across
                %dimension 2 (Note: averaged over TASK period samples)
                ERD_subject(s).pre.(task{j}).alpha = squeeze(mean(ERD_data(s).pre.ERD_alpha(find(ERD_data(s).pre_label == j), TrialOnset:TrialOnset+Task_time, channel.(chan_fields{s})(z)), 2));
                pre_alpha = cat(2, pre_alpha, ERD_subject(s).pre.(task{j}).alpha);
                %ERD_subject(s).pre.(task{j}).alpha_mean = mean(ERD_subject(s).pre.(task{j}).alpha);
                %ERD_subject(s).pre.(task{j}).alpha_std = std(ERD_subject(s).pre.(task{j}).alpha) ./ sqrt(25);
                ERD_subject(s).pre.(task{j}).beta = squeeze(mean(ERD_data(s).pre.ERD_beta(find(ERD_data(s).pre_label == j), TrialOnset:TrialOnset+Task_time, channel.(chan_fields{s})(z)), 2));
                pre_beta = cat(2, pre_beta, ERD_subject(s).pre.(task{j}).beta);
                %ERD_subject(s).pre.(task{j}).beta_mean = mean(ERD_subject(s).pre.(task{j}).beta);
                %ERD_subject(s).pre.(task{j}).beta_std = std(ERD_subject(s).pre.(task{j}).beta) ./ sqrt(25);
                ERD_subject(s).post.(task{j}).alpha = squeeze(mean(ERD_data(s).post.ERD_alpha(find(ERD_data(s).post_label == j), TrialOnset:TrialOnset+Task_time, channel.(chan_fields{s})(z)), 2));
                post_alpha = cat(2, post_alpha, ERD_subject(s).post.(task{j}).alpha);
                %ERD_subject(s).post.(task{j}).alpha_mean = mean(ERD_subject(s).post.(task{j}).alpha);
                %ERD_subject(s).post.(task{j}).alpha_std = std(ERD_subject(s).post.(task{j}).alpha) ./ sqrt(25);
                ERD_subject(s).post.(task{j}).beta = squeeze(mean(ERD_data(s).post.ERD_beta(find(ERD_data(s).post_label == j), TrialOnset:TrialOnset+Task_time, channel.(chan_fields{s})(z)), 2));
                post_beta = cat(2, post_beta, ERD_subject(s).post.(task{j}).beta);
                %ERD_subject(s).post.(task{j}).beta_mean = mean(ERD_subject(s).post.(task{j}).beta);
                %ERD_subject(s).post.(task{j}).beta_std = std(ERD_subject(s).post.(task{j}).beta) ./ sqrt(25);
            end
            ERD_subject(s).pre.(task{j}).alpha = pre_alpha;
            ERD_subject(s).pre.(task{j}).beta = pre_beta;
            ERD_subject(s).post.(task{j}).alpha = post_alpha;
            ERD_subject(s).post.(task{j}).beta = post_beta;
            ERD_subject(s).pre.(task{j}).alpha_mean = mean(ERD_subject(s).pre.(task{j}).alpha, 'all');
            ERD_subject(s).pre.(task{j}).alpha_std = std(ERD_subject(s).pre.(task{j}).alpha,0, 'all') ./ sqrt(length(channel.sub1) * 25);
            ERD_subject(s).pre.(task{j}).beta_mean = mean(ERD_subject(s).pre.(task{j}).beta, 'all');
            ERD_subject(s).pre.(task{j}).beta_std = std(ERD_subject(s).pre.(task{j}).beta,0, 'all') ./ sqrt(length(channel.sub1) * 25);
            ERD_subject(s).post.(task{j}).alpha_mean = mean(ERD_subject(s).post.(task{j}).alpha, 'all');
            ERD_subject(s).post.(task{j}).alpha_std = std(ERD_subject(s).post.(task{j}).alpha,0, 'all') ./ sqrt(length(channel.sub1) * 25);
            ERD_subject(s).post.(task{j}).beta_mean = mean(ERD_subject(s).post.(task{j}).beta, 'all');
            ERD_subject(s).post.(task{j}).beta_std = std(ERD_subject(s).post.(task{j}).beta,0, 'all') ./ sqrt(length(channel.sub1) * 25);
        end
    end
    %trial removal on Sub 1 post and and Sub 2 pre extension beta for ttest
    %{
    for j = 1:length(task)
        for k = 1:2
            if isequal(subfields{k}, 'pre') && isequal (task{j}, 'Extension')
                disp('1');
            else
                ERD_subject(1).(subfields{k}).(task{j}).beta(Art_indx.sub1.ext_pre_indx, :, :) = [];
                ERD_subject(1).(subfields{k}).(task{j}).alpha(Art_indx.sub1.ext_pre_indx, :, :) = [];
            end
            ERD_subject(1).(subfields{k}).(task{j}).beta = mean(ERD_subject(1).(subfields{k}).(task{j}).beta, 2);
            ERD_subject(1).(subfields{k}).(task{j}).alpha = mean(ERD_subject(1).(subfields{k}).(task{j}).alpha, 2);
        end
    end
    for j = 1:length(task)
        for k = 1:2
            if isequal(subfields{k}, 'post') && isequal (task{j}, 'Extension')
                disp('1');
            else
                ERD_subject(2).(subfields{k}).(task{j}).beta(Art_indx.sub2.ext_post_indx, :, :) = [];
                ERD_subject(2).(subfields{k}).(task{j}).alpha(Art_indx.sub2.ext_post_indx, :, :) = [];
            end
            ERD_subject(2).(subfields{k}).(task{j}).beta = mean(ERD_subject(2).(subfields{k}).(task{j}).beta, 2);
            ERD_subject(2).(subfields{k}).(task{j}).alpha = mean(ERD_subject(2).(subfields{k}).(task{j}).alpha, 2);
        end
    end
    %}
    
    %Average ERD over 5 electrodes
    for s = 1:2 %subjects
        for j = 1:length(task) %tasks
            for k = 1:2
                ERD_subject(s).(subfields{k}).(task{j}).beta = mean(ERD_subject(s).(subfields{k}).(task{j}).beta, 2);
                ERD_subject(s).(subfields{k}).(task{j}).alpha = mean(ERD_subject(s).(subfields{k}).(task{j}).alpha, 2); 
            end
        end
    end
    
    for s = 1:2 %subjects
        for j = 1:length(task) %tasks
                [prepost_h(s).(task{j}).alpha, prepost_p(s).(task{j}).alpha] = ttest2(ERD_subject(s).pre.(task{j}).alpha, ERD_subject(s).post.(task{j}).alpha, 'Alpha',0.05); 
                [prepost_h(s).(task{j}).beta, prepost_p(s).(task{j}).beta] = ttest2(ERD_subject(s).pre.(task{j}).beta, ERD_subject(s).post.(task{j}).beta, 'Alpha',0.05);
                if (prepost_h(s).(task{j}).alpha == 1)
                    disp('pre post alpha');
                    disp(task{j});
                    disp (s);
                end
                if (prepost_h(s).(task{j}).beta == 1)
                    disp('pre post beta');
                    disp(task{j});
                    disp (s);
                end
        end
    end
    
    %Unpaired t test for 3 class
    for s = 1:2 %subjects
        for p = 1:2 %pre or post
            for j = 1:length(task) %tasks
                for k = 1:length(task)
                    [sig_h(s).(subfields{p}).(task{j}).(task{k}).alpha, sig_p(s).(subfields{p}).(task{j}).(task{k}).alpha] = ttest2(ERD_subject(s).(subfields{p}).(task{j}).alpha, ERD_subject(s).(subfields{p}).(task{k}).alpha, 'Alpha',0.05);
                    [sig_h(s).(subfields{p}).(task{j}).(task{k}).beta, sig_p(s).(subfields{p}).(task{j}).(task{k}).beta] = ttest2(ERD_subject(s).(subfields{p}).(task{j}).beta, ERD_subject(s).(subfields{p}).(task{k}).beta, 'Alpha',0.05);
                    if (sig_h(s).(subfields{p}).(task{j}).(task{k}).alpha == 1)
                        disp('between tasks');
                        disp(task{j});
                        disp (s);
                    elseif (sig_h(s).(subfields{p}).(task{j}).(task{k}).beta == 1)
                        disp('between tasks');
                        disp(task{j});
                        disp (s);
                    end
                    
                end
            end
        end
    end
    %ANOVA for 3 class (pre and post -> alpha)
    for s = 1:2 %subjects
        for k = 1:2
            groups = [ones(1, size(ERD_subject(s).(subfields{k}).(task{1}).alpha,1)) 2*ones(1,size(ERD_subject(s).(subfields{k}).(task{2}).alpha,1)) 3*ones(1,size(ERD_subject(s).(subfields{k}).(task{3}).alpha,1))];
            data = [ERD_subject(s).(subfields{k}).(task{1}).alpha' ERD_subject(s).(subfields{k}).(task{2}).alpha' ERD_subject(s).(subfields{k}).(task{3}).alpha'];
            [p, table, stats] = anova1(data, groups);
            [sig(s).(subfields{k}).alpha, m, h, nms] = multcompare(stats,'alpha',.05);
        end
    end
     %ANOVA for 3 class (pre and post -> beta)
    for s = 1:2 %subjects
        for k = 1:2
            groups = [ones(1, size(ERD_subject(s).(subfields{k}).(task{1}).beta,1)) 2*ones(1,size(ERD_subject(s).(subfields{k}).(task{2}).beta,1)) 3*ones(1,size(ERD_subject(s).(subfields{k}).(task{3}).beta,1))];
            data = [ERD_subject(s).(subfields{k}).(task{1}).beta' ERD_subject(s).(subfields{k}).(task{2}).beta' ERD_subject(s).(subfields{k}).(task{3}).beta'];
            [p, table, stats] = anova1(data, groups);
            [sig(s).(subfields{k}).beta, m, h, nms] = multcompare(stats,'alpha',.05);
        end
    end
    close all;
    ERD_diff_sub1_alpha = ERD_subject(1).pre.(task{1}).alpha_mean - ERD_subject(1).pre.(task{2}).alpha_mean; 
    ERD_diff_sub1_ = ERD_subject(1).pre.(task{1}).alpha_mean - ERD_subject(1).pre.(task{2}).alpha_mean; 
    for s = 1:2
        for k = 1:2
            ERD_diff(s).(subfields{k}).alpha = abs(ERD_subject(s).(subfields{k}).(task{1}).alpha_mean - ERD_subject(s).(subfields{k}).(task{2}).alpha_mean);
            ERD_diff(s).(subfields{k}).beta = abs(ERD_subject(s).(subfields{k}).(task{1}).beta_mean - ERD_subject(s).(subfields{k}).(task{2}).beta_mean);
        end
    end
    %bar plotting
    fig = figure;
    for s = 1:2
        ERD_temp_alpha = [];
        ERD_temp_beta = [];
        ERD_alpha_std = []; ERD_beta_std = [];ERD_difference = [];
        for k = 1:2 %don't plot rest for now
            ERD_temp_alpha_temp = [ERD_subject(s).(subfields{k}).(task{1}).alpha_mean ERD_subject(s).(subfields{k}).(task{2}).alpha_mean];
            ERD_temp_alpha = cat(2, ERD_temp_alpha, (ERD_temp_alpha_temp));
            ERD_temp_alpha_temp = [ERD_subject(s).(subfields{k}).(task{1}).alpha_std ERD_subject(s).(subfields{k}).(task{2}).alpha_std];
            ERD_alpha_std = cat(2, ERD_alpha_std, (ERD_temp_alpha_temp));
            ERD_temp_beta_temp = [ERD_subject(s).(subfields{k}).(task{1}).beta_mean ERD_subject(s).(subfields{k}).(task{2}).beta_mean];
            ERD_temp_beta = cat(2, ERD_temp_beta, (ERD_temp_beta_temp));
            ERD_temp_beta_temp = [ERD_subject(s).(subfields{k}).(task{1}).beta_std ERD_subject(s).(subfields{k}).(task{2}).beta_std];
            ERD_beta_std = cat(2, ERD_beta_std, (ERD_temp_beta_temp));
            ERD_diff_temp = [ERD_diff(s).(subfields{k}).alpha ERD_diff(s).(subfields{k}).beta];
            ERD_difference = cat(2, ERD_difference, (ERD_diff_temp));
            
        end
        subplot(2,3,3*(s-1)+1)
        category = categorical({'Flex pre','Ext pre','Flex post', 'Ext post'});
        category = reordercats(category, {'Flex pre','Ext pre','Flex post', 'Ext post'});
        hb = bar(category, ERD_temp_alpha); hb.FaceColor = 'flat'; hb.CData(3,:) = [.5 0 .5];  hb.CData(4,:) = [.5 0 .5];
        hold on
        er = errorbar(category,ERD_temp_alpha,-ERD_alpha_std, ERD_alpha_std);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        hold off
        grid on; grid minor;
        ylabel('ERD/ERS (power spectrum) in %', 'fontweight', 'bold');
        set(gca, 'FontSize', 14);
        %set(gca, 'YScale', 'log')
        title(strcat('\alpha band: Subject', num2str(s)));
        %legend('pre', 'post');
        
        subplot(2,3,3*(s-1)+2)
        category = categorical({'Flex pre','Ext pre','Flex post', 'Ext post'});
        category = reordercats(category, {'Flex pre','Ext pre','Flex post', 'Ext post'});
        hb = bar(category, ERD_temp_beta);hb.FaceColor = 'flat'; hb.CData(3,:) = [.5 0 .5];  hb.CData(4,:) = [.5 0 .5];
        hold on
        er = errorbar(category,ERD_temp_beta,-ERD_beta_std, ERD_beta_std);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        hold off
        grid on; grid minor;
        ylabel('ERD/ERS (power spectrum) in %', 'fontweight', 'bold');
        set(gca, 'FontSize', 14);
        %set(gca, 'YScale', 'log')
        title(strcat('\beta band: Subject', num2str(s)));
        %legend('pre', 'post');
        
        subplot(2,3,3*(s-1)+3)
        category = categorical({'Pre: alpha','Pre: beta','Post: alpha', 'Post: beta'});
        category = reordercats(category, {'Pre: alpha','Pre: beta','Post: alpha', 'Post: beta'});
        hb = bar(category, ERD_difference); hb.FaceColor = 'flat'; hb.CData(3,:) = [.5 0 .5];  hb.CData(4,:) = [.5 0 .5];
        grid on; grid minor;
        ylabel('ERD/ERS (power spectrum) in %', 'fontweight', 'bold');
        set(gca, 'FontSize', 14);
        %set(gca, 'YScale', 'log')
        title(strcat('Difference in mean ERD of Flex and Ext: Subject', num2str(s)));
    end
   
    
   
        
        %saveas(fig,strcat('Graphs/ERD_ERS_bar.png' ));
end




