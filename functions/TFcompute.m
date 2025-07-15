%Time frequency computation (wavelet method)
%channel input as 1x2 integer (2 subjects)
function [sub_TF] = TFcompute(data, Fs, channel, TrialTime, Marker)
    %For spectrogram
    window = 256;
    noverlap = 128;
    % Freq to compute spectral data
    F = 5:30; 
    labels = [1, 2];%, 3]; %flex = 1; ext = 2; rest = 3;
    %Omit plotting for rest
    tasks = {'Flexion', 'Extension'};%, 'Rest'};
    chan_fields = {'sub1', 'sub2'};
    channel_list = data(1).pre(1).electrodes;
    %Concatenate runs together (75 trials per subject per session) - use
    %preprocessed EEG
    sub(1).pre_eeg = cat(1, data(1).pre(1).raw_extended, data(1).pre(2).raw_extended);
    sub(1).pre_label = cat(1, data(1).pre(1).labels, data(1).pre(2).labels);
    sub(2).pre_eeg = cat(1, data(2).pre(1).raw_extended, data(2).pre(2).raw_extended);
    sub(2).pre_label = cat(1, data(2).pre(1).labels, data(2).pre(2).labels);
    sub(1).post_eeg = cat(1, data(1).post(1).raw_extended, data(1).post(2).raw_extended);
    sub(1).post_label = cat(1, data(1).post(1).labels, data(1).post(2).labels);
    sub(2).post_eeg = cat(1, data(2).post(1).raw_extended, data(2).post(2).raw_extended);
    sub(2).post_label = cat(1, data(2).post(1).labels, data(2).post(2).labels);
    %Temporary - for GA alpha power plotting
    sub(1).pre_alpha_p = cat(1, data(1).pre(1).alpha_p, data(1).pre(2).alpha_p);
    sub(2).pre_alpha_p = cat(1, data(2).pre(1).alpha_p, data(2).pre(2).alpha_p);
    sub(1).post_alpha_p = cat(1, data(1).post(1).alpha_p, data(1).post(2).alpha_p);
    sub(2).post_alpha_p = cat(1, data(2).post(1).alpha_p, data(2).post(2).alpha_p);
    %Temporary - spectrogram plotting
    sub(1).pre_eeg_p = cat(1, data(1).pre(1).pre_raw_p, data(1).pre(2).pre_raw_p);
    
    for s = 1:2 %subjects
        for i = 1:length(labels)
            for z = 1%:length(channel.sub1)
                TF_power_pre = zeros(length(F),length(sub(1).pre_eeg(1,:,1)));
                TF_power_post = zeros(length(F),length(sub(1).post_eeg(1,:,1)));
                t = find(sub(s).pre_label == i);
                for k = 1:length(t) %trials of resp label
                    %Pre: Single trial spectral decomposition -> Complex Morlet
                    %wavelet, centfrq('cmor1 -1 ')*Fs./F, 'cmor1 -1 '
                    coefsi_pre = cwt(sub(s).pre_eeg(t(k),:,channel.(chan_fields{s})(z)), centfrq('cmor1 -1 ')*Fs./F, 'cmor1 -1 ');
                    %Magnitude of complex coefficients extracted, squared and averaged ->
                    %total power
                    TF_power_pre = TF_power_pre + abs(coefsi_pre).^2./(length(find(sub(s).pre_label == i)));
                end
                t = find(sub(s).post_label == i);
                for k = 1:length(t)
                    %Post
                    coefsi_post = cwt(sub(s).post_eeg(t(k),:,channel.(chan_fields{s})(z)),centfrq('cmor1 -1 ')*Fs./F, 'cmor1 -1 ');
                    TF_power_post = TF_power_post + abs(coefsi_post).^2./(length(find(sub(s).post_label == i)));
                end
               
            end
             %Store
                sub_TF(s).label(i).pre_coeff = 10*log10(TF_power_pre);
                sub_TF(s).label(i).post_coeff = 10*log10(TF_power_post);
        end
    end
    %% plotting
    Colors = {'r', 'k', 'b', 'g'};
    chan = {'C3', 'CP6'};
    for s = 1:2 %subjects
        fig=figure; 
        for i = 1:length(labels)           
            subplot(2,2,i)
            %TF of pre
            h = surface(TrialTime,F,sub_TF(s).label(i).pre_coeff);
            h.Annotation.LegendInformation.IconDisplayStyle = 'off';
            for p = 1:length(Marker.timestamp)
                xline(TrialTime(Marker.timestamp(p)), Colors{p}, 'LineWidth', 3, 'DisplayName', Marker.stamp_name{p});
            end
            legend;axis tight; shading flat; xlabel('Time (s)'); ylabel('Frequency (Hz)')
            title(strcat('Total power of Subject', int2str(s), " ", tasks{i}, " ", 'Pre,', " ", 'Channel:', chan{s}));
            c = colorbar; cl = caxis ; c.Label.String = 'Total Power(dB)'; 
            set(gca, 'FontSize', 14);
            
            %Corresponding alpha power GA (ERD)
%             subplot(2, 2,2)
%             plot (TrialTime, Alpha_GA_sub(s).label(i).pre); %GA alpha power
%             xlabel('Time (s)'); ylabel('Power (uV^2)'); grid on; grid minor;
%             title(strcat('Alpha Power GA at', " ",string(channel_list(channel(s))), " ", ',Subject:', int2str(s), " ", tasks{i}, " ", 'S1'));
            
            subplot(2,2,i+2)
            %TF of pre
            h = surface(TrialTime,F,sub_TF(s).label(i).post_coeff);
            h.Annotation.LegendInformation.IconDisplayStyle = 'off';
            for p = 1:length(Marker.timestamp)
                xline(TrialTime(Marker.timestamp(p)), Colors{p}, 'LineWidth', 3, 'DisplayName', Marker.stamp_name{p});
            end
            legend; axis tight; shading flat; xlabel('Time (s)'); ylabel('Frequency (Hz)')
            title(strcat('Total power of Subject', int2str(s), " ", tasks{i}, " ", 'Post,', " ", 'Channel:', chan{s}));
            c = colorbar; caxis(cl); c.Label.String = 'Total Power(dB)'; 
            set(gca, 'FontSize', 14);
            %Corresponding alpha power GA (ERD)
%             subplot(2, 2, 4)
%             plot (TrialTime, Alpha_GA_sub(s).label(i).post); %GA alpha power
%             xlabel('Time (s)'); ylabel('Power (uV^2)'); grid on; grid minor;
%             title(strcat('Alpha Power GA at', " ",string(channel_list(channel(s))), " ", ',Subject:', int2str(s), " ", tasks{i}, " ", 'S3'));
            %p = p+2;
            saveas(fig,strcat('Graphs/TF_plot_', tasks{i}, 'Subject', num2str(s), '.png' ));
        end
        
    end
    
    %figure; 
    %spectrogram(10*log10(GA_sub(1).label(1).pre), window ,noverlap ,F,Fs, 'yaxis');
%       view(2)
%       colormap jet;
      % h = colorbar;
     %set(h,'Ylim',[-20 10])
    %Maybe subsample output to reduce features dimension (processing
    %concerns)

 end
%    figure; 
%     imagesc(sub_TF(1).wav.label(1).pre_coeff);
%     figure;
%     surface(TrialTime,F,sub_TF(1).wav.label(1).pre_coeff);
%     axis tight
%     shading flat
%     xlabel('Time (s)')
%     ylabel('Frequency (Hz)')
%     colorbar


    %plotting
%     figure;
%     spectrogram(sub_TF(1).spec.label(1).pre_coeff ,window ,noverlap ,F,Fs);
%      view(2)
%      colormap jet;
% 
%    figure;
%             
%             figure;
%             [cfs,frq] = cwt(sub_TF(1).spec.label(1).pre_coeff,Fs);
%             surface(TrialTime,frq,abs(cfs))
%             shading flat
%             colorbar
