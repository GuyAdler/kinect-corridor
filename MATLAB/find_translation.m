function translation_vec = find_translation(vec1, vec2, start1, end2)
% finds a translation vector that moves the END of vec2 to match the START
% of vec1.

min_cut_sz = min(start1,end2);

vec2_trim = squeeze(vec2((end-min_cut_sz+1):end,skeleton.CM,:));
vec1_trim = squeeze(vec1(1:min_cut_sz,skeleton.CM,:));
translation_vec = mean(vec2_trim - vec1_trim);

end