clc; clear; close all;
addpath('DataUji');

% === Muat Model Training ===
load('EEG_Model.mat', 'TrainedModel', 'Mu', 'Sigma', 'Fs', 'K_MAX_HFD');
fprintf('Model EEG_Model.mat berhasil dimuat.\n');

% === Parameter Umum ===
SEGMENT_SAMPLES = Fs * 58;       % durasi sinyal yang diambil
POOR_SIGNAL_THRESHOLD = 51;      % batas noise poor signal

% === Ambil semua file dari folder DataUji ===
Uji_Netral = dir(fullfile('DataUji', 'Netral_*.csv'));
Uji_Rileks = dir(fullfile('DataUji', 'Rileks_*.csv'));
AllUjiFiles = [Uji_Netral; Uji_Rileks];

% === Inisialisasi ===
X_Test = [];
Y_Test = [];

for i = 1:length(AllUjiFiles)
    fprintf('🔹 Memproses file uji: %s...\n', AllUjiFiles(i).name);
    T = readtable(fullfile(AllUjiFiles(i).folder, AllUjiFiles(i).name));

    % --- Validasi kolom ---
    if ~ismember('eegRawValueVolts', T.Properties.VariableNames)
        warning('Kolom eegRawValueVolts tidak ditemukan pada %s', AllUjiFiles(i).name);
        continue;
    end
    if ~ismember('poorSignal', T.Properties.VariableNames)
        warning('Kolom poorSignal tidak ditemukan pada %s', AllUjiFiles(i).name);
        continue;
    end

    RawEEG = T.eegRawValueVolts;
    PoorSignal = T.poorSignal;

    % --- Ambil sinyal dengan kualitas baik ---
    CleanIndices = find(PoorSignal <= POOR_SIGNAL_THRESHOLD);
    if length(CleanIndices) < SEGMENT_SAMPLES
        warning('Data uji %s terlalu pendek.', AllUjiFiles(i).name);
        continue;
    end

    TargetSegment = RawEEG(CleanIndices(1):CleanIndices(1) + SEGMENT_SAMPLES - 1);

    % --- Wavelet decomposition ---
    [c, l] = wavedec(TargetSegment, 5, 'db4');
    D3 = wrcoef('d', c, l, 'db4', 3);
    D4 = wrcoef('d', c, l, 'db4', 4);
    Beta_Signal = D3 + D4;

    % --- Hitung Higuchi Fractal Dimension ---
    HFD_Feature = HiguchiFD(Beta_Signal, K_MAX_HFD);
    X_Test = [X_Test; HFD_Feature];

    % --- Tentukan label asli dari nama file ---
    if contains(AllUjiFiles(i).name, 'Netral', 'IgnoreCase', true)
        Y_Test = [Y_Test; "Netral"];
    elseif contains(AllUjiFiles(i).name, 'Rileks', 'IgnoreCase', true)
        Y_Test = [Y_Test; "Rileks"];
    else
        Y_Test = [Y_Test; "Unknown"];
    end
end

% === Normalisasi Data Uji ===
X_Test_Norm = (X_Test - Mu) ./ Sigma;

% === Prediksi Menggunakan Model ===
Y_Pred = predict(TrainedModel, X_Test_Norm);

% === Confusion Matrix ===
C = confusionmat(Y_Test, Y_Pred);
disp('----------------------------------------');
disp('📊 Confusion Matrix (Baris=Kelas Asli, Kolom=Prediksi)');
disp(array2table(C, 'VariableNames', {'Pred_Netral','Pred_Rileks'}, ...
                       'RowNames', {'True_Netral','True_Rileks'}));

% === Hitung Metrik Evaluasi ===
if size(C,1) == 2 && size(C,2) == 2
    TP = C(2,2);
    TN = C(1,1);
    FP = C(1,2);
    FN = C(2,1);

    Precision = TP / (TP + FP);
    Recall = TP / (TP + FN);
    F1 = 2 * (Precision * Recall) / (Precision + Recall);
    Accuracy = (TP + TN) / sum(C(:));

    fprintf('\n=== HASIL EVALUASI ===\n');
    fprintf('TP = %d | TN = %d | FP = %d | FN = %d\n', TP, TN, FP, FN);
    fprintf('Akurasi  : %.2f%%\n', Accuracy * 100);
    fprintf('Presisi  : %.2f%%\n', Precision * 100);
    fprintf('Recall   : %.2f%%\n', Recall * 100);
    fprintf('F1-Score : %.2f%%\n', F1 * 100);
else
    warning('Confusion matrix tidak sesuai (bukan 2x2)');
end

% === Visualisasi hasil prediksi ===
figure;
gscatter(1:length(Y_Test), zeros(size(Y_Test)), Y_Pred, 'br', 'xo');
title('Hasil Prediksi Emosi pada Data Uji');
xlabel('Index Sampel Uji');
ylabel('Kelas');
legend('Netral','Rileks');
grid on;

rmpath('DataUji');
