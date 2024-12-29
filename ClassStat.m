classdef ClassStat < handle
properties (SetAccess = private) % Переменные из параметров
    % Нужно ли визуализировать результаты
        isTransparent;

    % Из Signal
        % Исходная ЧД
            RawSampFreq;

    % Из FileManager
        % Путь файла сигнала
            FilePath;
end
properties (SetAccess = private) % Вычисляемые переменные
end
methods
    function obj = ClassStat(Params)
    % Конструктор

        % Выделение поля Stat структуры Params
            Stat = Params.Stat;
        % Переменные из параметров
            obj.isTransparent = Stat.isTransparent;
    
        % Выделение поля Signal структуры Params
            Signal = Params.Signal;
        % Переменные из Signal
            obj.RawSampFreq = Signal.RawSampFreq;
    
        % Выделение поля FileManager структуры Params
            FileManager = Params.FileManager;
        % Переменные из FileManager
            obj.FilePath = FileManager.FilePath;
    end

    function StartMessage(obj)
    % Вывод сообщения о начале компенсации сигнала

        fprintf('%s Компенсация сигнала ''%s''.\n', datestr(now), ...
            obj.FilePath);
    end

    function DoneMessage(obj, Sig)
    % Вывод сообщения о завершении компенсации сигнала

        % Энергия до компенсации
            EnergyBefore = sum(abs(Sig.Raw).^2);
        % После
            EnergyAfter = sum(abs(Sig.Compensated).^2);
        % Отношение энергий до и после
            EnergyRatio = EnergyAfter / EnergyBefore;

        % Вывод сообщений
            fprintf('%s Компенсирован сигнал ''%s''.\n', datestr(now), ...
                obj.FilePath);
            fprintf('\tЭнергия до и после: %.0f --> %.0f.\n', ...
                EnergyBefore, EnergyAfter);
            fprintf(['\tЭнергия увеличилась в %.2f раз(а) ', ...
                '(Уменьшилась в %.2f раз(а)).\n'], EnergyRatio, ...
                1/EnergyRatio);
            fprintf('\n');
    end
    
    function Visualize(obj, Sig, SamplerInds)
    % Визуализация результатов

        if obj.isTransparent
            return;
        end

        % СПСМ сигнала до и после компенсации
            % Инициализация и настройка окна с графиками
                figure("Name", obj.FilePath);
                ax = axes;

                set(ax, 'YScale', 'lin');
                hold on;
                grid on;
                xlabel('Частота, Гц');
                ylabel('СПСМ, дБм');

            % СПСМ до и после
                [Before.SPD, Before.F] = GetSPDEstFun(Sig.Raw, ...
                    obj.RawSampFreq);
                [After.SPD, After.F] = GetSPDEstFun(Sig.Compensated, ...
                    obj.RawSampFreq);
            % Построение графиков
                plot(Before.F, 10*log10(Before.SPD)); 
                plot(After.F, 10*log10(After.SPD)); 
                hold off;
            % Легенда 
                legend('До компенсации', 'После компенсации');

        % Оценка символььной синхронизации
            figure;
            stem(SamplerInds);
            xlabel('Время (номер кадра)');
            ylabel('Номер отсчёта с каждого кадра');
            ylim([0, max(SamplerInds)+1])
    end
end
end

