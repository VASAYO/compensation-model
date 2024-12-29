function DeleteObjects(Objs)
%
% Удаление всех объектов, используемых в цикле обработки одного набора
% параметров

        delete(Objs.FileManager);
        delete(Objs.FreqShifter);
        delete(Objs.Resampler);
        delete(Objs.RRCFilter);
        delete(Objs.Sampler);
        delete(Objs.PLL);
        delete(Objs.SignalRecovery);
        delete(Objs.Compensator);
        delete(Objs.Stat);
end
