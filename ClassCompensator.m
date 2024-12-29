classdef ClassCompensator < handle
properties (SetAccess = private) % Переменные из параметров
end
properties (SetAccess = private) % Вычисляемые переменные
end
methods
    function obj = ClassCompensator(Params) %#ok<INUSD> 
    % Конструктор

        % Процедура констуктора
    end

    function OutData = Step(obj, MainSignal, CopySignal) %#ok<INUSL> 
    % Вычитатель сигналов

        OutData = MainSignal - CopySignal(1:length(MainSignal));
    end
end
end

