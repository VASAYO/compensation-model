classdef ClassFreqShifter < handle
properties (SetAccess = private) % Переменные из параметров
    % Из Signal
        % Граничные значения полосы сигнала
            BandLims;
        % Исходная ЧД
            RawSampFreq;
end
properties (SetAccess = private) % Вычисляемые переменные
end
methods
    function obj = ClassFreqShifter(Params)
    % Конструктор

        % Выделение поля Signal структуры Params
            Signal = Params.Signal;
        % Инициализация значений переменных из Signal
            obj.BandLims = Signal.BandLims;
            obj.RawSampFreq = Signal.RawSampFreq;
    end
    
    function OutData = Step1(obj, InData)
    % Грубая подстройка частоты

        % Вектор времени
            t = (0:length(InData)-1).' / obj.RawSampFreq;
        % Комплексная экспонента
            ex = exp(-1j*2*pi*mean(obj.BandLims) * t);
        % Смещение по частоте
            OutData = InData .* ex;
    end
    function OutData = Step2(obj, InData)
    % Обратное смещение сигнала

        % Вектор времени
            t = (0:length(InData)-1).' / obj.RawSampFreq;
        % Комплексная экспонента
            ex = exp(1j*2*pi*mean(obj.BandLims) * t);
        % Смещение по частоте
            OutData = InData .* ex;
    end
end
end

