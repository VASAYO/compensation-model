function Objs = PrepareObjects(Params)
% 
% Функция инициализации объектов

        Objs.FileManager = ClassFileManager(Params);
        Objs.FreqShifter = ClassFreqShifter(Params);
        Objs.Resampler = ClassResampler(Params);
        Objs.RRCFilter = ClassRRCFilter(Params);
        Objs.SignalRecovery = ClassSignalRecovery(Params);
        Objs.AGC = ClassAGC(Params, Objs.SignalRecovery);
        Objs.Sampler = ClassSampler(Params);
        Objs.PLL = ClassPLL(Params);
        Objs.Compensator = ClassCompensator(Params);
        Objs.Criterium = ClassCriterium(Params);
        Objs.Stat = ClassStat(Params);
end

