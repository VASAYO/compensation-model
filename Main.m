function Main(FirstParamsNum, Step4ParamsNum)
%
% Главный запускаемый файл модели компенсации сигнала
%   Входных переменных может быть 0, 1 или 2. Значения по умолчанию:
%       FirstParamsNum = 1;
%       Step4ParamsNum = 1;
%
% Входные переменные:
%   Если имеется только одна входная переменная, то FirstParamsNum - массив
%       значений номеров наборов параметров, для которых нужно выполнить
%       моделирование.
%   Если входных переменных две, то FirstParamsNum, Step4ParamsNum
%       - номер первого набора параметров и шаг для перехода к последующему
%       набору параметров. Пара этих переменных предназначена, прежде
%       всего, для запуска модели на нескольких узлах.
%
% Выходные переменные: (В данный момент не реализовано)
%   Выходными переменными являются данные, по которым делать вывод о работе
%   алгоритма: частота ГУН ФАПЧ (VCOFreq), индексы сэмплера (Inds).

    % Очистка command window, закрытие всего
        clc;
        close all;

    % Проверим количество входных переменных
        if ~(nargin >= 0 && nargin <= 2)
            error(['Количество входных переменных Main должно быть ', ...
                '0, 1 или 2.']);
        end

    % Определим значения FirstParamsNum, Step4ParamsNum   
        if nargin == 0
            FirstParamsNum = 1;
            Step4ParamsNum = 1;
        elseif nargin == 1
            Step4ParamsNum = 1;
        else
            % Проверка корректности введённых значений
        end

    % Считывание параметров сигнала и настроек системы, отличающихся от
    % значений по умолчанию
        Params = ReadSetup();

    % Определим массив значений kVals - номеров параметров, для которых
    % должен быть выполнен расчёт (на данном узле)
        % Общее количество наборов параметров
            NumParams = length(Params);
        if nargin == 1
            kVals = FirstParamsNum;
        else
            kVals = FirstParamsNum : Step4ParamsNum : NumParams;
        end

    % Проверка значений kVals
        if (min(kVals) < 1) || (max(kVals) > NumParams)
            error('Недопустимое значение номера набора парметров');
        end        

    % Цикл по наборам параметров
        for k = 1:length(Params)

            % Установка значений по умолчанию
                Params{k} = SetParams(Params{k}, k);
            % Вычисление/проверка параметров
                Params{k} = CalcAndCheckParams(Params{k}, k);

            % Инициализация объектов
                Objs = PrepareObjects(Params{k});

            % Сообщение о начале компенсации
                Objs.Stat.StartMessage();

            % Загрузка сигнала из файла
                Sig.Raw = Objs.FileManager.StepImport();
            % Грубая подстройка частоты
                Sig.Shifted     = Objs.FreqShifter.Step1(Sig.Raw);
            % Передискретизация
                Sig.Resampled   = Objs.Resampler.Step1(Sig.Shifted);
            % RRC-фильтрация
                Sig.Filt        = Objs.RRCFilter.Step(Sig.Resampled);
            % Добавление АБГШ
                Sig.AddAWGN = Objs.Criterium.StepAdd(Sig.Filt);
            % Сэмплирование
                [Sig.Sampled, SamplerInds] = Objs.Sampler.Step( ...
                    Sig.AddAWGN ...
                );
%             % Временная команда для отладки
%                 subplot(1,2,1)
%                 stem(SamplerInds)
%                 subplot(1,2,2)
%                 histogram(diff(SamplerInds))
%                 return
            % Регулировка уровня
                [Sig.Adjusted, ChannelEst] = Objs.AGC.Step(Sig.Sampled);
            % ФАПЧ
                [Sig.Tuned, FreqOffset] = Objs.PLL.Step(Sig.Adjusted);
            % Команда для отладки
%                 histogram(angle(Sig.Tuned))
%                 return
            % Восстановление основного сигнала
                Sig.CopyUnestimated = Objs.SignalRecovery.Step( ...
                    Sig.Tuned, FreqOffset, ChannelEst, Objs.RRCFilter ...
                );
            % Применения метода оценки компенсации
                Sig.CopyResampled = Objs.Criterium.StepCorr( ...
                    Sig.CopyUnestimated);
            % Обратная передискретизация
                Sig.CopyShifted = Objs.Resampler.Step2(Sig.CopyResampled);
            % Сдвиг по частоте (обратное действие к грубой подстройке
            % частоты
                Sig.Copy = Objs.FreqShifter.Step2(Sig.CopyShifted);
            % Компенсация
                Sig.Compensated = Objs.Compensator.Step(Sig.Raw, ...
                    Sig.Copy);
            % Выгрузка результата
                Objs.FileManager.StepExport(Sig.Compensated, Sig.Copy);

            % Вывод сообщения о завершении
                Objs.Stat.DoneMessage(Sig);

            % Отображение результатов
                Objs.Stat.Visualize(Sig, SamplerInds);

            % Удаление объектов
                DeleteObjects(Objs);
        end
end
