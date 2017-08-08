function [ sorted ] = sort_videos( list )
% SORT_VIDEOS receives a list of video that is sorted by ASCII values,
%	in the format Video# (# is a number), and returns the list sorted
%	according to #.

sorted_hash = zeros(1,length(list));
for i=1:length(list)
    temp = strsplit(list{i},'o');
    sorted_hash(i) = str2num(cell2mat(temp(end)));
end
[~,I] = sort(sorted_hash);
sorted = list(I);


end
