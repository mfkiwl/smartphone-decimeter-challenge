% Configuration can be changed in Config class
config = Config.getInstance;
delete(config); % Delete previous instance of Config
config = Config.getInstance;

campaignPath = [config.obsDataPath config.campaignName filesep];
config.phoneNames = getValidDir(campaignPath);
nPhones = length(config.phoneNames);
% imuClean = struct();

if ~exist('imuClean', 'var')
    for iPhone = 1:nPhones
        fprintf('Evaluating %s/%s \n', config.campaignName, config.phoneNames{1})
        
        [phones, ~, ~, ~] = loadData();
%         [phoneRnx, imuRaw, ~, ~, ~, ref(iPhone)] = loadData();
        phones = preprocessIns(phones);
    end
end

dimXYZ = {'X', 'Y', 'Z'};
dimLla = {'Lat', 'Lon', 'Alt'};
for iPhone = 1:nPhones
   
    figure(1)
    subplot(nPhones, 1, iPhone)
    plot(phones(iPhone).ins.utcSeconds, phones(iPhone).ins.gyrBodyRadPerSec);
    legend(dimXYZ);
    xlabel('UTC Seconds'); ylabel('\omega (rad/s)');
    title(config.phoneNames{iPhone})
    
    for iDim = 1:3
        figure(2)
        subplot(nPhones, 3, (iPhone-1)*3+iDim)
        histogram(phones(iPhone).ins.gyrBodyRadPerSec(:, iDim));
        xlabel(['\omega_' dimXYZ{iDim} ' (rad/s)']);
        title(config.phoneNames{iPhone})
    end
    
    figure(3)
    subplot(nPhones, 1, iPhone)
    plot(phones(iPhone).ins.utcSeconds, phones(iPhone).ins.accBodyMps2);
    legend(dimXYZ);
    xlabel('UTC Seconds'); ylabel('f (m/s)');
    title(config.phoneNames{iPhone})
    
    for iDim = 1:3
        figure(4)
        subplot(nPhones, 3, (iPhone-1)*3+iDim)
        histogram(phones(iPhone).ins.accBodyMps2(:, iDim));
        xlabel(['f_' dimXYZ{iDim} ' (m/s)']);
        title(config.phoneNames{iPhone})
    end
    
%     ref2PosLlaInterp = interp1(phones(2).ref.utcSeconds, phones(2).ref.posLla, phones(1).ref.utcSeconds, 'spline');
    diffPos = geodetic2ecefVector(phones(1).ref.posLla) - geodetic2ecefVector(phones(2).ref.posLla);
%     diffPos = Lla2Ned(phones(1).ref.posLla, phones(2).ref.posLla);
    
    for iDim = 1:3
        figure(5)
        subplot(3, 1, iDim)
        plot(phones(1).ref.utcSeconds, diffPos(:, iDim))
%         ylabel([dimXYZ{iDim} '_E (m)'])
    end
    
    figure(6)
    plot(phones(1).ref.utcSeconds, vecnorm(diffPos, 2, 2))
    ylabel('Lever arm length (m)')
    
    figure(7)
    plot(phones(1).ref.utcSeconds, phones(2).ref.utcSeconds)
    xlabel(['UTC Seconds ' config.phoneNames{1}]); ylabel(['UTC Seconds ' config.phoneNames{2}]);
end