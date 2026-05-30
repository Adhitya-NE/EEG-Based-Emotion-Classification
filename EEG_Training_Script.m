clc; clear; close all;
addpath('TrainingData');

% Parameter
Fs = 512;                     
K_MAX_HFD = 15;               
K_FOLD_CV = 12;                
K_KNN = 3;                    
SEGMENT_SAMPLES = Fs * 58;    
POOR_SIGNAL_THRESHOLD = 10;   

% Ambil semua file dari folder
NetralFiles = dir(fullfile('TrainingData', 'Netral_*.csv'));
RileksFiles = dir(fullfile('TrainingData', 'Rileks_*.csv'));
AllFiles = [NetralFiles; RileksFiles];

X_HFD = [];
Y_Label = [];

% Loop semua file EEG
for i = 1:length(AllFiles)
    fprintf('Memproses file %s...\n', AllFiles(i).name);
    
    % Baca data EEG
    T = readtable(fullfile(AllFiles(i).folder, AllFiles(i).name));
    
    % Pastikan kolom ada
    if ~ismember('eegRawValueVolts', T.Properties.VariableNames)
        warning('Kolom eegRawValueVolts tidak ditemukan pada %s', AllFiles(i).name);
        continue;
    end
    if ~ismember('poorSignal', T.Properties.VariableNames)
        warning('Kolom poorSignal tidak ditemukan pada %s', AllFiles(i).name);
        continue;
    end
    
    RawEEG = T.eegRawValueVolts;
    PoorSignal = T.poorSignal;
    
    % Hapus bagian sinyal dengan kualitas buruk
    CleanIndices = find(PoorSignal <= POOR_SIGNAL_THRESHOLD);
    if length(CleanIndices) < SEGMENT_SAMPLES
        warning('Data %s terlalu pendek untuk diambil 60 detik sinyal.', AllFiles(i).name);
        continue;
    end
    
    TargetSegment = RawEEG(CleanIndices(1) : CleanIndices(1) + SEGMENT_SAMPLES - 1);
    
    % Wavelet decomposition (db4)
    [c, l] = wavedec(TargetSegment, 5, 'db4');
    D3 = wrcoef('d', c, l, 'db4', 3);
    D4 = wrcoef('d', c, l, 'db4', 4);
    
    % Beta band (gabungan D3 + D4)
    Beta_Signal = D3 + D4;
    
    % Hitung fitur HFD
    HFD_Feature = HiguchiFD(Beta_Signal, K_MAX_HFD);
    
    % Tambahkan ke dataset
    X_HFD = [X_HFD; HFD_Feature];
    
    if contains(AllFiles(i).name, 'Netral', 'IgnoreCase', true)
        Y_Label = [Y_Label; "Netral"];
    elseif contains(AllFiles(i).name, 'Rileks', 'IgnoreCase', true)
        Y_Label = [Y_Label; "Rileks"];
    else
        Y_Label = [Y_Label; "Unknown"];
    end
end

% --- Normalisasi ---
X_Raw_Sample = X_HFD;
Mu = mean(X_Raw_Sample);
Sigma = std(X_Raw_Sample);
X_Normalized = (X_HFD - Mu) ./ Sigma;

% --- Model KNN dengan K-Fold Cross Validation ---
Mdl = fitcknn(X_Normalized, Y_Label,...
    'NumNeighbors', K_KNN,...
    'CrossVal', 'on',...
    'KFold', K_FOLD_CV,...
    'Standardize', false);

Loss = kfoldLoss(Mdl);
Akurasi = 1 - Loss;
PredictedLabels = kfoldPredict(Mdl);
C = confusionmat(Y_Label, PredictedLabels);

% --- Hitung metrik evaluasi ---
if size(C,1) == 2 && size(C,2) == 2
    TP = C(2,2);
    TN = C(1,1);
    FP = C(1,2);
    FN = C(2,1);
    
    Precision = TP / (TP + FP);
    Recall = TP / (TP + FN);
    F1 = 2 * (Precision * Recall) / (Precision + Recall);
    
    % Akurasi ulang (validasi silang hasil)
    Accuracy = (TP + TN) / sum(C(:));
else
    warning('Confusion matrix tidak berukuran 2x2 — pastikan hanya ada 2 kelas.');
    TP = NaN; TN = NaN; FP = NaN; FN = NaN;
    Precision = NaN; Recall = NaN; F1 = NaN; Accuracy = NaN;
end

% --- Simpan model ---
TrainedModel = fitcknn(X_Normalized, Y_Label, ...
    'NumNeighbors', K_KNN, 'Standardize', false);
save('EEG_Model.mat', 'TrainedModel', 'Mu', 'Sigma', 'Fs', 'K_MAX_HFD');

% --- Output hasil ---
disp('========================================');
disp('✅ Model Pelatihan Selesai');
fprintf('Akurasi Validasi Silang (CV): %.2f%%\n', Akurasi * 100);
disp('----------------------------------------');
disp('📊 Confusion Matrix (Baris=Kelas Asli, Kolom=Prediksi)');
disp(array2table(C, 'VariableNames', {'Pred_Netral','Pred_Rileks'}, ...
                       'RowNames', {'True_Netral','True_Rileks'}));
disp('----------------------------------------');
fprintf('TP = %d | TN = %d | FP = %d | FN = %d\n', TP, TN, FP, FN);
fprintf('Akurasi  : %.2f%%\n', Accuracy * 100);
fprintf('Presisi  : %.2f%%\n', Precision * 100);
fprintf('Recall   : %.2f%%\n', Recall * 100);
fprintf('F1-score : %.2f%%\n', F1 * 100);
disp('========================================');
disp('Model dan parameter disimpan ke EEG_Model.mat');

rmpath('TrainingData');