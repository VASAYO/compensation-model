classdef ClassResampler < handle
properties (SetAccess = private) % Переменные из параметров
    % Новый коэффициент передискретизации
            NewSps;

    % Из Signal
        % Исходная частота дискретизации (ЧД) сигнала
            RawSampFreq;
        % Символьная скорость сигнала
            SymbRate;
end
properties (SetAccess = private) % Вычисляемые переменные
    % ЧД сигнала, на которой происходит обработка
            NewSampFreq;
end
methods
    function obj = ClassResampler(Params)
    % Конструктор

        % Выделение поля Resampler структуры Params
            Resampler       = Params.Resampler;
        % Переменные из Resampler
            obj.NewSps      = Resampler.NewSps;

        % Выделение поля Signal структуры Params
            Signal          = Params.Signal;
        % Переменные из Signal
            obj.RawSampFreq = Signal.RawSampFreq;
            obj.SymbRate    = Signal.SymbRate;

        % Вычисление частоты дискретизации, на которой будет происходит
        % обработка
            obj.NewSampFreq = obj.NewSps * obj.SymbRate;
    end
    function OutData = Step1(obj, InData)
    % Передискретизация сигнала перед обработкой
        
        OutData = ResamplingFun(InData, obj.RawSampFreq, ...
            obj.NewSampFreq);
    end

    function OutData = Step2(obj, InData)
    % Обратная передискретизация сигнала после компенсации

        OutData = ResamplingFun(InData, obj.NewSampFreq, ...
            obj.RawSampFreq);
    end
end
end
