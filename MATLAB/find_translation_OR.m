function translation_vec = find_translation(vec1, vec2)
% finds a translation vector that moves the END of vec2 to match the START
% of vec1.

%vec2_CM_end = squeeze(vec2(end,skeleton.CM,:));
%vec1_CM_begining = squeeze(vec1(1,skeleton.CM,:));
%translation_vec = -(vec1_CM_begining - vec2_CM_end);

vec2_CM_end = squeeze(vec2(end,:,:));
vec1_CM_begining = squeeze(vec1(1,:,:));
translation_vec = -(vec1_CM_begining - vec2_CM_end);
