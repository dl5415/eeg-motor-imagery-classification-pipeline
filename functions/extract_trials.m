%% Function that extracts trials

function trialData = extract_trials(subjectData, task_sec)
    fs = subjectData(1).pre(1).hdr.fs;
    electrodes = subjectData(1).pre(1).hdr.Label;
    num_electrodes = length(electrodes);
    
    trialData = struct;
    for s = 1:2
        for r = 1:2
            % account for different number of trials per run
            if r == 1
                num_trials = 45;
            else
                num_trials = 30;
            end
            % session 1, extract alpha, beta and preprocessed trials
            [trialData(s).pre(r).alpha, trialData(s).pre(r).labels] = get_trials(subjectData(s).pre(r).alpha, subjectData(s).pre(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'False');
            [trialData(s).pre(r).beta, ~] = get_trials(subjectData(s).pre(r).beta, subjectData(s).pre(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'False');
            %Trial extension to include fixation
            [trialData(s).pre(r).alpha_extended, ~] = get_trials(subjectData(s).pre(r).alpha, subjectData(s).pre(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'True');
            [trialData(s).pre(r).beta_extended, ~] = get_trials(subjectData(s).pre(r).beta, subjectData(s).pre(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'True');
            [trialData(s).pre(r).raw_extended, ~] = get_trials(subjectData(s).pre(r).pre_raw, subjectData(s).pre(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'True');
            [trialData(s).pre(r).pre_raw, ~] = get_trials(subjectData(s).pre(r).pre_raw, subjectData(s).pre(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'False');
            %instantaneous power of bands
            trialData(s).pre(r).alpha_p = (trialData(s).pre(r).alpha).^2;
            trialData(s).pre(r).beta_p = (trialData(s).pre(r).beta).^2;
            trialData(s).pre(r).pre_raw_p = (trialData(s).pre(r).pre_raw).^2;
            trialData(s).pre(r).electrodes = electrodes;
            trialData(s).pre(r).fs = fs;
            % session 3
            [trialData(s).post(r).alpha, trialData(s).post(r).labels] = get_trials(subjectData(s).post(r).alpha, subjectData(s).post(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'False');
            [trialData(s).post(r).beta, ~] = get_trials(subjectData(s).post(r).beta, subjectData(s).post(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'False');
            %Trial extension to include fixation
            [trialData(s).post(r).alpha_extended, ~] = get_trials(subjectData(s).post(r).alpha, subjectData(s).post(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'True');
            [trialData(s).post(r).beta_extended, ~] = get_trials(subjectData(s).post(r).beta, subjectData(s).post(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'True');
            [trialData(s).post(r).raw_extended, ~] = get_trials(subjectData(s).post(r).pre_raw, subjectData(s).post(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'True');
            [trialData(s).post(r).pre_raw, ~] = get_trials(subjectData(s).post(r).pre_raw, subjectData(s).post(r).hdr.EVENT, num_trials, num_electrodes, task_sec, fs, 'False');
            %instantaneous power of bands and raw
            trialData(s).post(r).alpha_p = (trialData(s).post(r).alpha).^2;
            trialData(s).post(r).beta_p = (trialData(s).post(r).beta).^2;
            trialData(s).post(r).pre_raw_p = (trialData(s).post(r).pre_raw).^2;
            trialData(s).post(r).electrodes = electrodes;
            trialData(s).post(r).fs = fs;
        end
    end
end

%% Helper functions

function [trials, labels] = get_trials(signal, event, num_trials, num_electrodes, task_sec, fs, fixation_include)
    if isequal (fixation_include, 'False')
        task_len = task_sec*fs;
    else
        %fixation length = 1.5s
        task_len = (task_sec + 1.5)*fs;
    end
    
    trials = zeros(num_trials, task_len, num_electrodes);
    labels = zeros(num_trials, 1);

    for t = 1:num_trials
        if isequal (fixation_include, 'False')
            %Start index: start of task cue (100,300,400)
            event_ind = 5*(t-1) + 4;
            labels(t) = decode_label(event.TYP(event_ind));
        else
            %Extending to include fixation
            event_ind = 5*(t-1) + 3;
            labels(t) = decode_label(event.TYP(event_ind+1));
        end
        start_ind = event.POS(event_ind);
        %End index: end of task (102,302,402)
        end_ind = start_ind + task_len - 1;
        trials(t,:,:) = signal(start_ind:end_ind,:);
    end
end

function y = decode_label(x)
    flex = 1;
    ext = 2;
    rest = 3;
    if x == 100
        y = flex;
    else
        if x == 300
            y = ext;
        else
            if x == 400
                y = rest;
            else
                % shouldn't reach here
                y = 0;
            end
        end
    end
end
