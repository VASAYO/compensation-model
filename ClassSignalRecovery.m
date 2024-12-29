classdef ClassSignalRecovery < handle
properties (SetAccess = private) % Переменные из параметров
    % Из Signal
        % Частота дискретизации
            RawSampFreq;
        % Тип модуляции
            ModType;
        % Порядок модуляции
            ModOrder;
        % Ротация созвездия
            PhaseRotation;    
        % Границы полосы пропускания сигнала
            BandLims;
end
properties (SetAccess = private) % Вычисляемые переменные
    % Маппера и демаппера
        Mapper;
        DeMapper
end
methods
    function obj = ClassSignalRecovery(Params)
    % Конструктор

        % Выделение поля Signal структуры Params
            Signal = Params.Signal;
        % Инициализация значений переменных из Signal
            obj.RawSampFreq = Signal.RawSampFreq;
            obj.ModType = Signal.ModType;
            obj.ModOrder = Signal.ModOrder;
            obj.PhaseRotation = Signal.PhaseRotation;
            obj.BandLims = Signal.BandLims;


        % Функции маппера или демаппера
            if strcmp(obj.ModType, 'PSK')

                obj.Mapper = @(x) pskmod(x, obj.ModOrder, ...
                    obj.PhaseRotation, "gray", "InputType","bit" ...
                );
                obj.DeMapper = @(x) pskdemod(x, obj.ModOrder, ...
                    obj.PhaseRotation, "gray", "OutputType","bit" ...
                );
            else

            end
    end
    
    function OutData = Step(obj, InData, FreqOffset, ChannelEst, RRCFilter)
    % Восстановление основного сигнала

        % Позиции в массиве, соответствующие расположению модуляционных
        % символов
            NonzeroInds = (abs(InData) ~= 0);
        % Ремодуляция полученных символов
            RemodSymbs = obj.Mapper(obj.DeMapper(InData(NonzeroInds)));
        % Расположение символов на исходные позиции
            RemodSymbsPosition = zeros(size(InData));
            RemodSymbsPosition(NonzeroInds) = RemodSymbs;
        % Формирующий фильтр
            FiltOut = RRCFilter.Step(RemodSymbsPosition);
        % Добавление оценки частотной отстройки канала
            SymbsOffset = FiltOut .* ...
                exp(1j * 2 * pi * cumsum(FreqOffset));
        % Добавление оценки амплитудных искажений канала
            OutData = SymbsOffset .* ChannelEst;
    end
end
end
