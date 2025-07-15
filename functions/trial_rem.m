function trialData = trial_rem (trialData,Art_indx)
    task = 2; %extension only
    fields = fieldnames(trialData(1).pre); 
    fields(11:end) = []; %get rid of last two cells
    %subject 1 pre
    for r = 1:2 %run numbers
         indx = find(trialData(1).pre(r).labels == task);
         if r == 1
             trial_indx = Art_indx.sub1.ext_pre_indx(find(Art_indx.sub1.ext_pre_indx<15));
         else
             trial_indx = Art_indx.sub1.ext_pre_indx(find(Art_indx.sub1.ext_pre_indx>15));
             trial_indx = trial_indx - 15;
         end
        for k = 1:length(fields)
            %Subject 1 pre
           trialData(1).pre(r).(fields{k})(indx(trial_indx),:,:) = []; 
        end
    end   
      %subject 2 post
    for r = 1:2 %run numbers
         indx = find(trialData(2).post(r).labels == task);
         if r == 1
             trial_indx = Art_indx.sub2.ext_post_indx(find(Art_indx.sub2.ext_post_indx<15));
         else
             trial_indx = Art_indx.sub2.ext_post_indx(find(Art_indx.sub2.ext_post_indx>15));
             trial_indx = trial_indx - 15; %15 trials in run 1
         end
        for k = 1:length(fields)
            %Subject 1 pre
           trialData(2).post(r).(fields{k})(indx(trial_indx),:,:) = []; 
        end
    end 

end