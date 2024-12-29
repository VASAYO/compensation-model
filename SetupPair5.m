    FileManager.FilePath                = "C:\Users\Андре\OneDrive\Документы\Политех\СТЦ\corellation\Записи от 19.11.2024\Птц 2024_10_xx\Pair 5\OutSum_4800.bin";
    FileManager.NumSamples              = Inf;
    FileManager.Format                  = 'single';
    FileManager.SaveSubstractorSignal   = 1;
    
    Signal.toCompensate     = 1;
    Signal.RawSampFreq      = 4800000;
    Signal.SymbRate         = 3e6;
    Signal.BandLims         = [-1820 1820]*1e3 - 12960;
    Signal.ModType          = 'PSK';
    Signal.ModOrder         = 4;
    Signal.PhaseRotation    = pi/4;
    
    Resampler.NewSps = 3;

    RRCFilter.RollOff = 0.2;

    Sampler.SymbsPerFrame = 1000;

    Criterium.isTransparent = 0;
    Criterium.SNRdB     = 10;
    Criterium.FrameT    = 0.5e-3;
    
    PLL.Par1    = 1000;
    PLL.Par2    = 100;
    
    Stat.isTransparent = false;
% End of Params

%     FileManager.FilePath    = "C:\Users\Андре\OneDrive\Документы\Политех\СТЦ\corellation\Записи от 19.11.2024\Птц 2024_10_xx\Pair 5\CompensatedTemp\DataCompensated.bin";
%     FileManager.NumSamples  = Inf;
%     FileManager.Format      = 'single';
%     
%     Signal.toCompensate     = 0;
%     Signal.RawSampFreq      = 4800000;
%     Signal.SymbRate         = 85336;
%     Signal.BandLims         = [1838 1955] * 1e3;
%     Signal.ModType          = 'PSK';
%     Signal.ModOrder         = 4;
%     Signal.PhaseRotation    = pi/4;
%     
%     Resampler.NewSps        = 20;
% 
%     RRCFilter.RollOff       = 0.30;
%     
%     PLL.Par1                = 1000;
%     PLL.Par2                = 100;
%     
%     Stat.isTransparent      = false;
