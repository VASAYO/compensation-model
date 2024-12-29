classdef ClassFileManager < handle  
properties (SetAccess = private) % Переменные из параметров
    % Полный путь к файлу
        FilePath;
    % Число первых отсчётов, которые будут считаны с файла
        NumSamples;
    % Формат записи чисел в файле
        Format;

    % Имя папки с результатом
        ResultDirName;
    % Имя файлов с результатом
        ResultFileName;

    % Нужно ли сохранять вычитаемый сигнал
        SaveSubstractorSignal;
end
properties (SetAccess = private) % Вычисляемые переменные
    % Разделительный знак
        PathDelimiter;

    % Путь к папке файла
        FileDirPath;
    % Имя файла
        FileName;
    % Расширение файла
        FileExt;

    % Существует ли .json?
        isJsonExist;
    % Путь к .json
        JsonPath;
    % Содержимое .json
        JsonData;

    % Путь папки с результатом
        ResultDirPath;
    % Путь результата
        ResultFilePath;
    % Путь .json результата 
        ResultJsonPath;
end
methods
    function obj = ClassFileManager(Params)
    % Конструктор
    
        % Выделим поля Params, необходимые для инициализации
            FileManager = Params.FileManager;
        % Инициализация значений переменных из параметров
            obj.FilePath = FileManager.FilePath;
            obj.NumSamples = FileManager.NumSamples;
            obj.Format = FileManager.Format;
            obj.ResultDirName = FileManager.ResultDirName;
            obj.ResultFileName = FileManager.ResultFileName;
            obj.SaveSubstractorSignal = ...
                FileManager.SaveSubstractorSignal;

        % Определение разделительного знака при указании пути
            if isunix
                obj.PathDelimiter = '/';
            elseif ispc
                obj.PathDelimiter = '\';
            else
                error('Не удалось определить платформу.');
            end

        % Если разделитель является последним символом в пути к файлу
        % или папке, отбрасываем его
            if obj.FilePath(end) == obj.PathDelimiter
                obj.FilePath(end) = [];
            end

        % Позиции разделителей и точек в пути сигнала
            DelInds = find(obj.FilePath == obj.PathDelimiter);
            DotInds = find(obj.FilePath == '.');
        % Имя файла
            obj.FileName = obj.FilePath(DelInds(end)+1:DotInds(end)-1);
        % Расширение файла
            obj.FileExt = obj.FilePath(DotInds(end):end);
        % Путь к каталогу файла
            obj.FileDirPath = obj.FilePath(1:DelInds(end)-1);

        % Путь .json файла
            obj.JsonPath = [ ...
                obj.FilePath(1:end-length(obj.FileExt)) ...
                strrep(obj.FilePath(end-length(obj.FileExt)+1:end), ...
                    obj.FileExt, '.json' ...
                ) ...
            ];
        % Поиск .json файла
            if exist(obj.JsonPath, "file")
                obj.isJsonExist = true;
            else
                obj.isJsonExist = false;
            end
        % Если .json файл существует, считаем его содержимое
            if obj.isJsonExist
                % Откроем файл
                    fid = fopen(obj.JsonPath);

                if fid < 0
                    error('Не удалось открыть файл ''%s''.\n', ...
                        obj.JsonPath);
                end

                % Считаем содержимое 
                    obj.JsonData = fread(fid);
                % Закроем файл
                    fclose(fid);
            else
                obj.JsonData = [];
            end

        % Путь папки с результатом
            obj.ResultDirPath = [obj.FileDirPath obj.PathDelimiter ...
                obj.ResultDirName];
        % Путь результата
            obj.ResultFilePath = [obj.ResultDirPath ...
                obj.PathDelimiter obj.ResultFileName obj.FileExt];
        % Путь .json результата 
            obj.ResultJsonPath = [ ...
                obj.ResultFilePath(1:end-length(obj.FileExt)) ...
                strrep(obj.ResultFilePath( ...
                    end-length(obj.FileExt)+1:end), ...
                    obj.FileExt, '.json' ...
                ) ...
            ];
    end
    
    function OutData = StepImport(obj)
    % Загрузка сигнала из файла

        % Откроем файл
            fid = fopen(obj.FilePath);

        if fid < 0
            error('Не удалось открыть файл ''%s''.\n', obj.FilePath);
        end

        % Считаем данные 
            TempData = fread(fid, 2 * obj.NumSamples, obj.Format);

        % Отформатируем данные
            OutData = TempData(1:2:end) + 1j * TempData(2:2:end);
    end

    function StepExport(obj, InData, SubstractorSig)
    % Выгрузка результата

        % Форматируем данные для записи
            ToWrite = zeros(2, length(InData));
            ToWrite(1, :) = real(InData);
            ToWrite(2, :) = imag(InData);

        % Создаём папку с результатом
            if ~exist(obj.ResultDirPath, 'dir')
                mkdir(obj.ResultDirPath);
            end

        % Открываем файл в режиме записи
            fid = fopen(obj.ResultFilePath, "w");

        if fid == -1
            error(['не удалось открыть файл ''%s'' в режиме ' ...
                'записи.\n'], obj.ResultFilePath);
        end

        % Записываем данные в файл
            fwrite(fid, ToWrite, obj.Format);
        % Закрываем файл
            fclose(fid);

        % Если у исходного файла был .json, перезапишем его
            if obj.isJsonExist

                % Открываем файл в режиме записи
                    fid = fopen(obj.ResultJsonPath, "w");

                if fid == -1
                    error(['не удалось открыть файл ''%s'' в ' ...
                        'режиме записи.\n'], obj.ResultJsonPath);
                end
                % Записываем данные в файл
                    fwrite(fid, obj.JsonData);
                % Закрываем файл
                    fclose(fid);
            end

        % При необходимости, сохраним вычитамемый сигнал
            if obj.SaveSubstractorSignal

                % Форматируем сигнал для записи
                    ToWrite = zeros(2, length(SubstractorSig));
                    ToWrite(1, :) = real(SubstractorSig);
                    ToWrite(2, :) = imag(SubstractorSig);

                % Путь файла с вычитаемым сигналом
                    SubstractorFilePath = [obj.ResultDirPath, ...
                        obj.PathDelimiter, 'SubstractorSignal', ...
                        obj.FileExt];

                % Откроем файл в режиме записи
                    fid = fopen(SubstractorFilePath, 'w');
                % Если открыть/создать файл не получилось, выдаём ошибку
                    if fid == -1
                        error(['не удалось открыть файл ''%s'' в ' ...
                            'режиме записи.\n'], obj.SubstractorFilePath);
                    end
                % Записываем данные в файл
                    fwrite(fid, ToWrite, obj.Format);
                % Закрываем файл
                    fclose(fid);

                % Если существует .json файл, создадим его и для файла с
                % вычитаемым сигналом
                    if obj.isJsonExist

                        % Путь .json файла
                            SubstractorJsonPath = [ ...
                                SubstractorFilePath( ...
                                    1:end-length(obj.FileExt) ...
                                ), ...
                                '.json' ...
                            ];

                        % Открываем файл
                            fid = fopen(SubstractorJsonPath, 'w');
                        % Если открыть/создать файл не получилось, выдаём 
                        % ошибку
                            if fid == -1
                                error(['не удалось открыть файл ''%s''' ...
                                    ' в режиме записи.\n'], ...
                                    obj.SubstractorJsonPath);
                            end
                        % Записываем содержимое
                            fwrite(fid, obj.JsonData);
                        % Закрываем файл
                            fclose(fid);
                    end
            end
    end
end
end
