classdef ClassAGC < handle
properties (SetAccess = private) % Переменные из параметров
    % Интервал оценки уровня сигнала, с
        LevelEstInterval;
    % Частота дискретизации
        NewSampFreq;
end
properties (SetAccess = private) % Вычисляемые переменные
    % Средняя энергия сигнального созвездия
        Es;
end

methods
    function obj = ClassAGC(Params, SignalRecovery)
    % Конструктор

        % Выделим поля Params, необходимые для инициализации
            AGC = Params.AGC;
            Signal = Params.Signal;
        % Инициализация значений переменных из параметров
            obj.LevelEstInterval = AGC.LevelEstInterval;
            obj.NewSampFreq = Signal.NewSampFreq;

        % Точки сигнального созвездия 
            Bits = de2bi(0:SignalRecovery.ModOrder-1).';
            Bits = Bits(:);
            Dots = SignalRecovery.Mapper(Bits);
        % Средняя энергия сигнального созвездия
            obj.Es = mean(Dots .* conj(Dots));
    end
    function [OutData, ChannelEst] = Step(obj, InData)
    % Оценка коэффициента передачи канала

        % Длина кадра 
            FrameLen = round(obj.LevelEstInterval * obj.NewSampFreq);

        % Дополнение сигнала нулями
            if mod(length(InData), FrameLen) ~= 0

                Buf = [InData; ...
                    zeros(FrameLen - mod(length(InData), FrameLen), 1)];
            else
                Buf = InData;
            end
        % Разделение сигнала на кадры
            Frames = reshape(Buf, FrameLen, []);
        % Память под результат
            OutData = zeros(size(Frames));
            ChannelEst = zeros(size(Frames));
        % Покадровая обработка
            for i = 1:size(Frames, 2)

                % Индексы позиций, на которых находятся мод-нные символы
                    SymbsInds = (Frames(:, i) ~= 0);
                % Массив символов в кадре
                    Symbs = Frames(SymbsInds, i);
                % Средняя энергия символа
                    Eav = mean(Symbs .* conj(Symbs));
                % Оценка амплитудного коэффициента
                    mu = sqrt(Eav / obj.Es);

                % Регулировка уровня
                    OutData(:, i) = Frames(:, i) / mu;
                % Запись оценки ослабления канала
                    ChannelEst(:, i) = mu;
            end

        OutData = OutData(1:length(InData)).';
        ChannelEst = ChannelEst(1:length(InData)).';
    end
end
end

