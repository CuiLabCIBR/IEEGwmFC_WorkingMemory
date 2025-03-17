clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220
ft_defaults;
cd('templateAtlas');
orgWMatlas = ft_read_mri('rICBM_DTI_81_WMPM_60p_FMRIB58.nii.gz');
WMatlasLabel = {'MidCerebellarP', 'PontineCrossTract', 'GenuCorpusC', 'BodyCorpusC', 'SpleniumCorpusC', ... % 1-5
    'Fornix', 'Corticospinal', 'Corticospinal', 'MedLemniscus', 'MedLemniscus', ... % 6-10
    'InfCerebellarP', 'InfCerebellarP', 'SupCerebellarP', 'SupCerebellarP', 'CerebellarP', ... % 11-15
    'CerebellarP', 'AntInternalCapsule', 'AntInternalCapsule', 'PostInternalCapsule', 'PostInternalCapsule', ...% 16-20
    'RetInternalCapsule', 'RetInternalCapsule', 'AntCoronaR', 'AntCoronaR', 'SupCoronaR', ... % 21-25
    'SupCoronaR', 'PostCoronaR', 'PostCoronaR', 'ThalamicR', 'ThalamicR', ... % 26-30
    'SagittalStratum', 'SagittalStratum', 'ExternalCapsule', 'ExternalCapsule', 'CingulumCingulate', ... % 31-35
    'CingulumCingulate', 'CingulumHipp', 'CingulumHipp', 'FornixStriaTerm', 'FornixStriaTerm', ... % 36-40
    'SupLongitudinalF', 'SupLongitudinalF', 'SupFrontoOccipitalF', 'SupFrontoOccipitalF', 'InfFrontoOccipitalF', ...% 41-45
    'InfFrontoOccipitalF', 'UncinateFasciculus', 'UncinateFasciculus', 'TapetumCorpusC', 'TapetumCorpusC', ... % 46-50
    'SupFrontalB', 'SupFrontalB', 'MidFrontalB', 'MidFrontalB', 'InfFrontalB', ... % 51-55
    'InfFrontalB', 'PrecentralB', 'PrecentralB', 'PostcentralB', 'PostcentralB', ...% 56-60
    'SupParietalB', 'SupParietalB', 'ParietoTempB', 'ParietoTempB', 'TemporalB', ...% 61-65
    'TemporalB', 'OccipitalB', 'OccipitalB'}; % 66-68
WMatlasLabel = WMatlasLabel';
N = 0;
for n = 1:length(WMatlasLabel)
    if ~strcmp(WMatlasLabel{n}, 'none')
        N = N + 1;
        newWMatlasLabel{N} = WMatlasLabel{n}; 
    end
end
for n1 = 1:length(newWMatlasLabel)
    for n2 = 1:length(newWMatlasLabel)
        if  strcmp(newWMatlasLabel{n1}, newWMatlasLabel{n2})
            labelmat(n1, n2) = 1;
        end
    end
end
for n = 1:size(labelmat, 1)
    a = min(find(labelmat(n, :)==1));
    uniqueWMatlasLabel{a} = newWMatlasLabel{a};
end
N = 0;
for n = 1:length(uniqueWMatlasLabel)
    if ~isempty(uniqueWMatlasLabel{n})
        N = N + 1;
        newUniqueWMatlasLabel{N, 1} = uniqueWMatlasLabel{n};
    end
end
data = orgWMatlas.anatomy;
newData = zeros(size(data));
for x = 1:size(data, 1)
    for y = 1:size(data, 2)
        for z = 1:size(data, 3)
            index = data(x, y, z);
            if index > 0
                for n = 1:length(newUniqueWMatlasLabel)
                    if strcmp(WMatlasLabel{index}, newUniqueWMatlasLabel{n})
                        newData(x, y, z) = n;
                    end
                end
            end
        end
    end
end
newWMatlas = orgWMatlas;
newWMatlas.anatomy = newData;
ft_write_mri('ICBM_DTI_81_60p_reorgan_allROI.nii.gz', newWMatlas);
save('ICBM_DTI_81_60p_reorgan_allROI.mat', "newUniqueWMatlasLabel");