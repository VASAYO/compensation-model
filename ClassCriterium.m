classdef ClassCriterium < handle
properties (SetAccess = private) % Переменные из параметров
    % Нужно ли проводить оценку созданной копии сигнала
        isTransparent;
    % Отношение мощности сигнала к мощности вспомогательного АБГШ (дБ)
        SNRdB;
    % Длительность кадра, на котором проходит анализ (с)
        FrameT;
    % Порог вынесения решения от 0 до 1
        Threshold;

    % Из Signal
        % Частота дискретизации (Гц)
            NewSampFreq;
end
properties (SetAccess = private) % Вычисляемые переменные
    % Вектор отсчётов шума
        Noise;
end
methods
    function obj = ClassCriterium(Params)
    % Конструктор

        % Выделяем поле Criterium структуры Params
            Criterium           = Params.Criterium;
        % Переменные из Criterium
            obj.isTransparent   = Criterium.isTransparent;
            obj.SNRdB           = Criterium.SNRdB;
            obj.FrameT          = Criterium.FrameT;
            obj.Threshold       = Criterium.Threshold;

        % Выделяем поле Signal структуры Params
            Signal          = Params.Signal;
        % Переменные из Signal
            obj.NewSampFreq = Signal.NewSampFreq;
    end

    function OutData = StepAdd(obj, InData)
    % Добавление вспомогательного шума

        if obj.isTransparent
            OutData = InData;
            return
        end

        % Мощность сигнала
            SPow = mean(InData .* conj(InData));
        % Мощность шума
            NPow = SPow / 10^(obj.SNRdB/10);
        % Генерация шума
            obj.Noise = randn(length(InData), 2) * [1; 1j] / sqrt(2);
            obj.Noise = obj.Noise * sqrt(NPow);

        % Добавление шума
            OutData = InData + obj.Noise;
    end

    function OutData = StepCorr(obj, InData)
    % Определение необходимости компенсации того или иного участка

        if obj.isTransparent
            OutData = InData;
            return
        end

        % Длина кадра в отсчётах
            SampsPerFrame = ceil(obj.FrameT * obj.NewSampFreq);

        % Дополнение сигнала (и шума) нулями, если его длина не кратна 
        % длине кадра
            if mod(length(InData), SampsPerFrame) ~= 0
                BufInData = [InData; ...
                    zeros(SampsPerFrame - ...
                        mod(length(InData), SampsPerFrame), 1 ...
                    ) ...
                ];
                obj.Noise = [obj.Noise; ...
                    zeros(SampsPerFrame - ...
                        mod(length(InData), SampsPerFrame), 1 ...
                    ) ...
                ];
            else
                BufInData = InData;
            end

        % Разделение сигнала и шума на кадры (столбцы матрицы)
            SigFrames   = reshape(BufInData, SampsPerFrame, []);
            NoiseFrames = reshape(obj.Noise, SampsPerFrame, []);

        % Вычисление коэффициента корреляции сигнала и шума в каждом кадре
            CorrCoeffs = zeros(1, size(SigFrames, 2));
            for i = 1:size(SigFrames, 2)

                % Энергии
                    E1 = sum(abs(SigFrames(:, i)).^2);
                    E2 = sum(abs(NoiseFrames(:, i)).^2);

                % Коэффициент корреляции
                    CorrCoeffs(i) = dot(NoiseFrames(:, i), ...
                        SigFrames(:,i)) / sqrt(E1*E2);
            end

        % Вынесение решения о проведении компенсации на длительности кадра
            Decisions = (CorrCoeffs < obj.Threshold);

        % Зануление сигнала там, где компенсировать не нужно
            OutData = SigFrames .* Decisions;
            
            OutData = OutData(1:length(InData)).';
    end
end
end
