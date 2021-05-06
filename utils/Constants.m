classdef Constants < handle
    %CONSTANTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        CELERITY = 299792458;       % m/s
        OMEGA_E = 7.2921151467e-5;  % rad/s
        EARTH_RADIUS = 6371e3;      % m
        
        GPS_L1_HZ = 1575.42e6;      % Hz
        
        MAX_GPS_PRN = 100;
        MAX_GAL_PRN = 100;
        MAX_BDS_PRN = 100;
    end
    
end

