function [ sorted ] = sort_dir( list_skel )
sorted_hash = zeros(1,length(list_skel));
for i=1:length(list_skel)
    temp = strsplit(list_skel(i).name,'-');
    sorted_hash(i) = str2num(cell2mat(temp(1)));
end
[~,I] = sort(sorted_hash);
sorted = list_skel(I);


end

