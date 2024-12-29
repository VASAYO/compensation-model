function Params = SetParams(inParams, ParamsNumber)

    % Пересохраним входные данные
        Params = inParams;

    % Имена полей структуры Params верхнего уровня    
        FieldNames = { ...
            'FileManager', ...
            'Signal', ...
            'Resampler', ...
            'RRCFilter', ...
            'Sampler', ...
            'AGC', ...
            'PLL', ...
            'SignalRecovery', ...
            'Compensator', ...
            'Criterium', ...
            'Stat' ...
        };

    for n = 1:length(FieldNames) % Цикл по всем полям Params верхнего
            % уровня
        % Если поле верхнего уровня не существует, его надо создать
            if ~isfield(Params, FieldNames{n})
                Params.(FieldNames{n}) = [];
            end
        % Сделаем указатель на функцию
            Fun = str2func(['SetParams', FieldNames{n}]);
        % Вызов функции, инициализирующей параметры нижнего уровня
            Params.(FieldNames{n}) = Fun(Params.(FieldNames{n}), ...
                ParamsNumber);
    end

end
function FileManager = SetParamsFileManager(inFileManager, ParamsNumber)
    
    % Пересохраним входные данные
        FileManager = inFileManager;

    % Путь к компенсируемому файлу
        if ~isfield(FileManager, 'FilePath')
            FileManager.FilePath = 0;
        end

    % Число считываемых отсчётов
        if ~isfield(FileManager, 'NumSamples')
            FileManager.NumSamples = +Inf;
        end

    % Формат записи отсчтов в файл
        if ~isfield(FileManager, 'Format')
            FileManager.Format = 'short';
        end

    % Имя папки с результатом
        if ~isfield(FileManager, 'ResultDirName')
            FileManager.ResultDirName = 'Compensated';
        end
    % Имя файла с результатом
        if ~isfield(FileManager, 'ResultFileName')
            FileManager.ResultFileName = 'DataCompensated';
        end

    % Нужно ли сохранять вычитаемый сигнал (пока что не реализовано)
        if ~isfield(FileManager, 'SaveSubstractorSignal')
            FileManager.SaveSubstractorSignal = false;
        end
end
function Signal = SetParamsSignal(inSignal, ParamsNumber)

    % Пересохраним входные данные
        Signal = inSignal;

    % Нужно ли выполнять компенсацию сигнала
        if ~isfield(Signal, 'toCompensate')

            Signal.toCompensate = false;
        end

    % Частота дискретизации сигнала
        if ~isfield(Signal, 'RawSampFreq')

            error('Укажите значение ''Signal.RawSampFreq''\n');
        end

    % Символьная скорость сигнала
        if ~isfield(Signal, 'SymbRate')

            error('Укажите значение ''Signal.SymbRate''\n');
        end

    % Массив с частотами пропускания
        if ~isfield(Signal, 'BandLims')

            error('Укажите значение ''Signal.BandLims''\n');
        end 

    % Вид модуляции 
        if ~isfield(Signal, 'ModType')

            Signal.ModType = 'PSK';
        else
            if ~(strcmp(Signal.ModType, 'PSK'))

                error('Недопустимое значение ''Signal.ModType''\n');
            end
        end 

    % Порядок модуляции 
        if ~isfield(Signal, 'ModOrder')

            Signal.ModOrder = 4;
        else
            if Signal.ModOrder < 2

                error('Недопустимое значение ''Signal.ModOrder''\n');
            end
        end

    % Ротация созвездия 
        if ~isfield(Signal, 'PhaseRotation')

            Signal.PhaseRotation = pi/4;
        end
end
function Resampler = SetParamsResampler(inResampler, ...
    ParamsNumber) %#ok<*INUSD> 

    % Пересохраним входные данные
        Resampler = inResampler;

    % Коэффициент передискретизации, на котором происходит обработка
        if ~isfield(Resampler, 'NewSps')
            
            error('Укажите значение ''Resampler.NewSps''\n');
        end
end
function RRCFilter = SetParamsRRCFilter(inRRCFilter, ParamsNumber)
    % Пересохраним входные данные
        RRCFilter = inRRCFilter;

    % Коэффициент сглаживания
        if ~isfield(RRCFilter, 'RollOff')

            RRCFilter.RollOff = 0.2;
        end

    % Длина RRC-фильтра
        if ~isfield(RRCFilter, 'Span')

            RRCFilter.Span = 50;
        end
end
function Sampler = SetParamsSampler(inSampler, ParamsNumber)

    % Пересохраним входные данные
        Sampler = inSampler;

    % Число символов, используемых в точечной оценке символьной 
    % синхронизации для каждого кадра 
        if ~isfield(Sampler, 'SymbsPerFrame')

            Sampler.SymbsPerFrame = 1e3;
        end
end
function AGC = SetParamsAGC(inAGC, ParamsNumber)

    % Пересохраним входные данные
        AGC = inAGC;

    % Интервал оценки уровня сигнала, с
        if ~isfield(AGC, 'LevelEstInterval')

            AGC.LevelEstInterval = 100e-3;
        end
end
function PLL = SetParamsPLL(inPLL, ParamsNumber)

    % Пересохраним входные данные
        PLL = inPLL;

    % Нужно ли проводить подстройку фазы и частоты
        if ~isfield(PLL, 'isTransparent')

            PLL.isTransparent = false;
        end

    % Параметры петлевого фильтра
        if ~isfield(PLL, 'Par1')

            PLL.Par1 = 12079;
        end
        if ~isfield(PLL, 'Par2')

            PLL.Par2 = 100;
        end
end
function SignalRecovery = SetParamsSignalRecovery(inSignalRecovery, ...
    ParamsNumber)

    % Пересохраним входные данные
        SignalRecovery = inSignalRecovery;
end
function Compensator = SetParamsCompensator(inCompensator, ParamsNumber)

    % Пересохраним входные данные
        Compensator = inCompensator;
end
function Criterium = SetParamsCriterium(inCriterium, ParamsNumber)

    % Пересохраним входные данные
        Criterium = inCriterium;

    % Нужно ли проводить оценку созданной копии сигнала
        if ~isfield(Criterium, 'isTransparent')
    
            Criterium.isTransparent = true;
        end

    % Отношение мощности сигнала и мощности шума (дБ)
        if ~isfield(Criterium, 'SNRdB')
            Criterium.SNRdB = 20;
        end

    % Длительность кадра, на котором проходит анализ, с
        if ~isfield(Criterium, 'FrameT')
            Criterium.FrameT = 100e-3;
        end

    % Порог вынесения решения от 0 до 1
        if ~isfield(Criterium, 'Threshold')
            Criterium.Threshold = 0.1;
        end
end
function Stat = SetParamsStat(inStat, ParamsNumber)

    % Пересохраним входные данные
        Stat = inStat;

    % Нужно ли визуализировать результаты
        if ~isfield(Stat, 'isTransparent')

            Stat.isTransparent = true;
        end
end
