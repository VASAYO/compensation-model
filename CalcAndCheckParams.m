function Params = CalcAndCheckParams(inParams, ParamsNum)
%
% В этой функции можно проверять правильность установки комбинаций
% параметров и/или выполнять расчёт параметров одного класса, зависящих от
% параметров других классов, важно при этом понимать, что функция
% CalcAndCheckParams вызывается до создания объектов, т.е. до вызова
% конструкторов.

    % Пересохраним входные данные
        Params = inParams;

    % Проверка, что в наборе параметра указан путь сигнала
        if Params.Signal.toCompensate && ...
                isequal(Params.FileManager.FilePath, 0)
    
            error(['Укажите путь компенсируемого сигнала в наборе ', ...
                'параметров %d'], ParamsNum);
        end

    % Если путь тип "string", конвертируем его в
    % "char"
        if isstring(Params.FileManager.FilePath)
            Params.FileManager.FilePath = convertStringsToChars( ...
                Params.FileManager.FilePath);
        end
        if isstring(Params.FileManager.ResultFileName)
            Params.FileManager.ResultFileName = convertStringsToChars( ...
                Params.FileManager.ResultFileName);
        end
        if isstring(Params.FileManager.ResultDirName)
            Params.FileManager.ResultDirName = convertStringsToChars( ...
                Params.FileManager.ResultDirName);
        end

    % Вычисление ЧД после передискртизации
        Params.Signal.NewSampFreq = Params.Resampler.NewSps * ...
            Params.Signal.SymbRate;
end

