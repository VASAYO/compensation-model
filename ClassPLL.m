classdef ClassPLL < handle
properties (SetAccess = private) % Переменные из параметров
    % Нужно ли проводить подстройку фазы и частоты
        isTransparent;
    % Параметры петлевого фильтра
        Par1;
        Par2;

    % Из Signal
        % Тип модуляции
            ModType;
        % Порядок модуляции
            ModOrder;
        % Ротация созвездия
            PhaseRotation;
end
properties (SetAccess = private) % Вычисляемые переменные
end
methods
    function obj = ClassPLL(Params)
    % Конструктор

        % Выделим поля Params, необходимые для инициализации
            PLL = Params.PLL;
        % Инициализация значений переменных из параметров
            obj.isTransparent = PLL.isTransparent;
            obj.Par1 = PLL.Par1;
            obj.Par2 = PLL.Par2;

        % Выделение поля Signal структуры Params
            Signal = Params.Signal;
        % Инициализация значений переменных из Signal
            obj.ModType = Signal.ModType;
            obj.ModOrder = Signal.ModOrder;
            obj.PhaseRotation = Signal.PhaseRotation;
    end
    
    function [OutData, OffsetFreq] = Step(obj, InData)
    % Подстройка фазы и частоты

        % Проверка блока на прозрачность
            if obj.isTransparent
    
                OutData = InData;
                OffsetFreq = zeros(size(InData));
                return
            end


        if strcmp(obj.ModType, 'PSK') % Вид модуляции

            % Инициализация переменных
                SamplePrev = 1;             % Значение прошлого отсчёта
                VCOFreq = 0;                % Частота ГУН
                PhaseCorrection = 0;        % Корректирующая фаза
            % Пересохранение результатов
                OutData = InData;
            % Память под частоту ГУН
                OffsetFreq = zeros(size(OutData));
            % Цикл по отсчётам
                for i = 1:length(OutData)

                    % Подстройка фазы
                        OutData(i) = OutData(i) * ...
                            exp(-1j * PhaseCorrection);

                    % Дискриминатор
                        % Сохранение в память текущего отсчёта
                            SampCurrent = OutData(i);
                        % Ошибка фазы
                            while ~( ...
                                angle(SampCurrent) >= ...
                                (obj.PhaseRotation-pi/obj.ModOrder) ...
                                            && ...
                                angle(SampCurrent) < ...
                                (obj.PhaseRotation+pi/obj.ModOrder) ...
                            )
                
                                SampCurrent = SampCurrent * ...
                                    exp(1j*2*pi/obj.ModOrder);
                            end
                            PhaseErr = angle(SampCurrent * ...
                                exp(-1j * obj.PhaseRotation));
                            DeltaPhase = angle(SampCurrent * ...
                                conj(SamplePrev));

                    % Петлевой фильтр и ГУН
                        % Частота ГУН
                            VCOFreq = VCOFreq + DeltaPhase/obj.Par1  + ...
                                PhaseErr/(2*obj.Par1);
                        % Частота ГУН, выводимая вне функции
                            OffsetFreq(i) = VCOFreq/(2*pi) + PhaseErr / ...
                                (2*obj.Par1*2*pi) * obj.Par2;
                        % Вычисление значения коррекции фазы следующего
                        % отсчёта
                            PhaseCorrection = PhaseCorrection + ...
                                VCOFreq + PhaseErr/(2*obj.Par1) * obj.Par2;

                        % Запись в память текущего отсчёта 
                            SamplePrev = SampCurrent;
                end
        else
            % Здесь должна быть реализация ФАПЧ для других видов модуляции
        end
    end
end
end
