classdef ClassRRCFilter < handle
    properties (SetAccess = private) % Переменные из параметров
        % Коэффициент сглаживания
            RollOff;
        % Длина RRC-фильтра
            Span;

        % Из Resampler
            % Коэффициент передискретизации
                Sps;
    end
    properties (SetAccess = private) % Вычисляемые переменные
        % Отсчёты RRC-импульса
            h;
    end
    methods
        function obj = ClassRRCFilter(Params)
        % Конструктор

            % Выделяем поле RRCFilter структуры Params
                RRCFilter = Params.RRCFilter;
            % Переменные из RRCFilter
                obj.RollOff = RRCFilter.RollOff;
                obj.Span = RRCFilter.Span;

            % Выделение поля Resampler структуры Params
                Resampler = Params.Resampler;
            % Переменные из Resampler
                obj.Sps = Resampler.NewSps;

            % Отсчёты RRC-импульса
                obj.h = rcosdesign(obj.RollOff, obj.Span, obj.Sps, 'sqrt');
        end
        
        function OutData = Step(obj, InData)
        % RRC-фильтрация

            OutData = conv(InData, obj.h, 'same');
        end
    end
end

