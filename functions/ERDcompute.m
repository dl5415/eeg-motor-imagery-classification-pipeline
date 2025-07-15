% percentage change in ERD in task period compared to baseline (rest task
% period)
function [sub,  Sub1_artef, Sub2_artef] = ERDcompute(data, TrialOnset, Fs)
%Concatenate runs together (alpha and beta power)
%Sub1 pre
sub(1).pre_alpha = cat(1, data(1).pre(1).alpha_p, data(1).pre(2).alpha_p);
sub(1).pre_beta = cat(1, data(1).pre(1).beta_p, data(1).pre(2).beta_p);
sub(1).pre_label = cat(1, data(1).pre(1).labels, data(1).pre(2).labels);
%Sub1 post
sub(1).post_alpha = cat(1, data(1).post(1).alpha_p, data(1).post(2).alpha_p);
sub(1).post_beta = cat(1, data(1).post(1).beta_p, data(1).post(2).beta_p);
sub(1).post_label = cat(1, data(1).post(1).labels, data(1).post(2).labels);
%Sub2 pre
sub(2).pre_alpha = cat(1, data(2).pre(1).alpha_p, data(2).pre(2).alpha_p);
sub(2).pre_beta = cat(1, data(2).pre(1).beta_p, data(2).pre(2).beta_p);
sub(2).pre_label = cat(1, data(2).pre(1).labels, data(2).pre(2).labels);
%Sub2 post
sub(2).post_alpha = cat(1, data(2).post(1).alpha_p, data(2).post(2).alpha_p);
sub(2).post_beta = cat(1, data(2).post(1).beta_p, data(2).post(2).beta_p);
sub(2).post_label = cat(1, data(2).post(1).labels, data(2).post(2).labels);
task = [{'flex','ext','rest'}];
Task_time = 4 * Fs;
for s = 1:2 %subjects
    %Rest task period (label 3) picked as reference (average power)
    %Step 1: av power of each rest trial in respective session (pre and
    %post)
    sub(s).pre.restGA_av_alpha_p = mean(sub(s).pre_alpha(find(sub(s).pre_label == 3), TrialOnset:TrialOnset+Task_time, :), 2);
    %Step 2: average of this av power (across trials) -> returns one scalar per electrode
    sub(s).pre.restGA_av_alpha_p = reshape(mean(sub(s).pre.restGA_av_alpha_p, 1),[1,32]);
    %Repeat for beta
    sub(s).pre.restGA_av_beta_p = mean(sub(s).pre_beta(find(sub(s).pre_label == 3), TrialOnset:TrialOnset+Task_time, :), 2);
    sub(s).pre.restGA_av_beta_p = reshape(mean(sub(s).pre.restGA_av_beta_p, 1),[1,32]);
    %Repeat for post sessions
    sub(s).post.restGA_av_alpha_p = mean(sub(s).post_alpha(find(sub(s).post_label == 3), TrialOnset:TrialOnset+Task_time, :), 2);
    sub(s).post.restGA_av_alpha_p = reshape(mean(sub(s).post.restGA_av_alpha_p, 1),[1,32]);
    sub(s).post.restGA_av_beta_p = mean(sub(s).post_beta(find(sub(s).post_label == 3), TrialOnset:TrialOnset+Task_time, :), 2);
    sub(s).post.restGA_av_beta_p = reshape(mean(sub(s).post.restGA_av_beta_p, 1),[1,32]);
    %To normalise, subtract mean baseline from each trial's instant power, and divide by
    %this baseline (ERD)
    for k = 1:32 %channels
        sub(s).pre.ERD_alpha(:,:,k) = (sub(s).pre_alpha(:,:,k) - sub(s).pre.restGA_av_alpha_p(k))./sub(s).pre.restGA_av_alpha_p(k) .* 100;
        sub(s).pre.ERD_beta(:,:,k) = (sub(s).pre_beta(:,:,k) - sub(s).pre.restGA_av_beta_p(k))./sub(s).pre.restGA_av_beta_p(k) .* 100;
        sub(s).post.ERD_alpha(:,:,k) = (sub(s).post_alpha(:,:,k) - sub(s).post.restGA_av_alpha_p(k))./sub(s).post.restGA_av_alpha_p(k) .* 100;
        sub(s).post.ERD_beta(:,:,k) = (sub(s).post_beta(:,:,k) - sub(s).post.restGA_av_beta_p(k))./sub(s).post.restGA_av_beta_p(k) .* 100;
    end
    %Averaged ERD value (across trials) of each electrode (for each task)
    for j = 1:length(task) %tasks
        %Extract task 1 ERD, and compute their grand average across
        %dimension 1 (trials)
        sub(s).pre.(task{j}).ERD_alpha = squeeze(mean(sub(s).pre.ERD_alpha(find(sub(s).pre_label == j), :, :), 1));
        sub(s).pre.(task{j}).ERD_beta = squeeze(mean(sub(s).pre.ERD_beta(find(sub(s).pre_label == j), :, :), 1));
        sub(s).post.(task{j}).ERD_alpha = squeeze(mean(sub(s).post.ERD_alpha(find(sub(s).post_label == j), :, :), 1));
        sub(s).post.(task{j}).ERD_beta = squeeze(mean(sub(s).post.ERD_beta(find(sub(s).post_label == j), :, :), 1));
    end
    %beta ERD at all channels, averaged across task window  + fixation
    j = 2; %extension
    sub(s).pre.(task{j}).ERD_beta_artefact = mean(mean(sub(s).pre.ERD_beta(find(sub(s).pre_label == j), :, :), 3), 2);
    sub(s).post.(task{j}).ERD_beta_artefact = mean(mean(sub(s).post.ERD_beta(find(sub(s).post_label == j), :, :), 3), 2);
   
    
end
 %subject 1 extension pre beta
 [Sub1_artef.ext_pre, Sub1_artef.ext_pre_indx] = maxk(sub(1).pre.(task{2}).ERD_beta_artefact, 3);
 %subject 2 extension post beta
 [Sub2_artef.ext_post, Sub2_artef.ext_post_indx] = maxk(sub(2).post.(task{2}).ERD_beta_artefact, 4);

end