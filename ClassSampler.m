classdef ClassSampler < handle
properties (SetAccess = private) % Переменные из параметров
    % Число тактовых интервалов в одном кадре
        SymbsPerFrame;

    % Из Resampler
        % Коэффициент передискретизации
            Sps;
end
properties (SetAccess = private) % Вычисляемые переменные
end
methods
    function obj = ClassSampler(Params)
    % Конструктор

        % Выделяем поле Sampler структуры Params
            Sampler = Params.Sampler;
        % Переменные из Sampler
            obj.SymbsPerFrame = Sampler.SymbsPerFrame;

        % Выделение поля Resampler структуры Params
            Resampler = Params.Resampler;
        % Переменные из Resampler
            obj.Sps = Resampler.NewSps;
    end
    
    function [OutData, Inds] = Step(obj, InData)
    % Сэмплирование сигнала с выхода СФ

        % Длина кадра
            FrameLen = obj.Sps * obj.SymbsPerFrame;
        % Добавление нулей в конце сигнала, чтобы число отсчётов нацело
        % делилось на длину кадра
            if mod(length(InData), FrameLen) ~= 0

                % Дополнение нулями
                    BufInSignal = [InData; ...
                        zeros(FrameLen - ...
                        mod(length(InData), FrameLen), 1)];
            else
                BufInSignal = InData;
            end
        % Создание трёхмерной матрицы: SPS x N x M, где SPS (строк) - 
        % число отсчётов на тактовый интервал, N (столбцов) - число 
        % тактовых интервалов в кадре, M (листов) - количество таких 
        % кадров
            ThreeDim = reshape( ...
                BufInSignal, obj.Sps, obj.SymbsPerFrame, []);
        % Вычисляем мощность каждого отсчёта
            InstPows = ThreeDim .* conj(ThreeDim);
        % Суммирование по отсчётам с одинаковым индексом внутри 
        % тактового интервала в каждом кадре
            Sums = squeeze(sum(InstPows, 2));
        % Выбираем индекс отсчёта в каждом кадре
            [~, Inds] = max(Sums);
        % Деление входного сигнала на кадры такой же длины
            Frames = reshape(BufInSignal, FrameLen, []);
        % Зануление всех отсчётов кроме каждого n-го в i-м кадре, 
        % где n = Inds(i)
            for i = 1:size(Frames, 2)
                % Вспомогательная логическая матрица
                    tmp = circshift(mod((1:size(Frames, 1)).', ...
                        obj.Sps) == 0, ...
                        -(obj.Sps - Inds(i)));
                % Поэлементное перемножение
                    Frames(:, i) = Frames(:, i) .* tmp;
            end
        % Выпрямление сигнала и удаление нулей в конце
            OutData = Frames(1:length(InData)).';
    end
end
end
