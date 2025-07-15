function topoVideoMaker(topoStruct,chanlocs,time)
%TOPOVIDEOMAKER Summary of this function goes here
%  
subjects = length(topoStruct);
signal_labels = fieldnames(topoStruct);
topo_str = fieldnames(topoStruct(1).(signal_labels{1}));
task_session_string = {'Flex S1','Ext S1','Rest S1','Flex S2','Ext S2','Rest S2'};
topo_limits = [-50 50];
for s=1:subjects
    for m=1:length(signal_labels)
        vid_name = strcat('sub',num2str(s),'_',signal_labels{m},'.avi');
        for t=1:length(time)
            if t == 1
                set(gca,'nextplot','replacechildren');
                w = VideoWriter(vid_name);
                w.FrameRate = 256;
                open(w);
            end
            tic
            close all
            figure('Position',[0 0 800 800])
            for count=1:length(topo_str)
                subplot(2,3,count)
                topoplot(topoStruct(s).(signal_labels{m}).(topo_str{count})(t,:),chanlocs,...
                    'maplimits',topo_limits);
                title([{strcat("Subject: ",num2str(s)," ",task_session_string{count})}...
                {strcat(signal_labels{m}," Time: ", num2str(time(t),'%.2f')," seconds")}],'Interpreter','none')
                colorbar('Ticks',topo_limits(1):10:topo_limits(2))
            end
            frame = getframe(gcf);
            frame.cdata = imresize(frame.cdata,[420 570]);
            size(frame.cdata)
            writeVideo(w,frame);
            toc
            display((t/length(time)*100),'% percent done of frames')
        end
        close(w)
    end
end

end

%% Helper Functions
