function [] = play_points_simple(walking)

play_start = 1;
play_end = size(walking,1)+1 ;
delay = 0.05;

player = pcplayer([(min(min(walking(:,:,1)))-0.5) (max(max(walking(:,:,1)))+0.5)],...
                  [(min(min(walking(:,:,2)))-0.5) (max(max(walking(:,:,2)))+0.5)],...
                  [(min(min(walking(:,:,3)))-0.5) (max(max(walking(:,:,3)))+0.5)], 'MarkerSize', 100);
i = play_start;

while isOpen(player)
    skel = connect_skeleton(squeeze(walking(i,1:25,:)) );
    ptCloud = pointCloud(skel,'Color',[repmat([0 50 255], 25,1);repmat([0 0 125],190,1)]);
    view(player,ptCloud);

    i = i + 1;
    if i == play_end
        i = play_start;
    end
    pause(delay);
end