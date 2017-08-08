classdef skeleton
    %SKELETON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant = true)
        AnkleLeft  	  	= 15  	; 
        AnkleRight 		= 19  	; 
		ElbowLeft		= 6  	; 
		ElbowRight		= 10  	; 
		FootLeft		= 16  	; 
		FootRight		= 20  	; 
		HandLeft		= 8  	; 
		HandRight		= 12  	; 
		HandTipLeft		= 22  	; 
		HandTipRight	= 24  	; 
		Head			= 4  	; 
		HipLeft			= 13  	; 
		HipRight		= 17  	; 
		KneeLeft		= 14  	; 
		KneeRight		= 18  	; 
		Neck			= 3  	; 
		ShoulderLeft	= 5  	; 
		ShoulderRight	= 9  	; 
		SpineBase		= 1  	; 
		SpineMid		= 2  	; 
		SpineShoulder	= 21  	; 
		ThumbLeft		= 23  	; 
		ThumbRight		= 25  	; 
		WristLeft		= 7  	; 
		WristRight		= 11  	; 
        CM              = 26    ;
		Names			= {'SpineBase', 'SpineMid', 'Neck', 'Head', 'ShoulderLeft', 'ElbowLeft', ...
						   'WristLeft', 'HandLeft', 'ShoulderRight', 'ElbowRight', 'WristRight', ...
						   'HandRight', 'HipLeft', 'KneeLeft', 'AnkleLeft', 'FootLeft', 'HipRight', ...
						   'KneeRight', 'AnkleRight', 'FootRight', 'SpineShoulder', 'HandTipLeft', ...
						   'ThumbLeft', 'HandTipRight', 'ThumbRight', 'CM'};
                       
        NumPoints       = 26
    end
    
    methods
    end
    
end

%Names{AnkleLeft} = 'AnkleLeft';
%Names{AnkleRight} = 'AnkleRight';
%Names{ElbowLeft} = 'ElbowLeft';
%Names{ElbowRight} = 'ElbowRight';
%Names{FootLeft} = 'FootLeft';
%Names{FootRight} = 'FootRight';
%Names{HandLeft} = 'HandLeft';
%Names{HandRight} = 'HandRight';
%Names{HandTipLeft} = 'HandTipLeft';
%Names{HandTipRight} = 'HandTipRight';
%Names{Head} = 'Head';
%Names{HipLeft} = 'HipLeft';
%Names{HipRight} = 'HipRight';
%Names{KneeLeft} = 'KneeLeft';
%Names{KneeRight} = 'KneeRight';
%Names{Neck} = 'Neck';
%Names{ShoulderLeft} = 'ShoulderLeft';
%Names{ShoulderRight} = 'ShoulderRight';
%Names{SpineBase} = 'SpineBase';
%Names{SpineMid} = 'SpineMid';
%Names{SpineShoulder} = 'SpineShoulder';
%Names{ThumbLeft} = 'ThumbLeft';
%Names{ThumbRight} = 'ThumbRight';
%Names{WristLeft} = 'WristLeft';
%Names{WristRight} = 'WristRight';
%Names{CM} = 'CM';