% --- File: EEG_Plot_TrainingData.m ---
clear; clc;

FOLDER_PATH = 'TrainingData'; % Pastikan ada subfolder TrainingData di dalam direktori kode ini
Fs = 512;                 % Frekuensi sampling
PLOT_DURATION = 5;        % Durasi data yang ditampilkan (detik)
SAMPLE_COUNT = Fs * PLOT_DURATION; 

% Ambil semua file berdasarkan pola nama
NetralFiles = dir(fullfile(FOLDER_PATH, 'Netral_*.csv'));
SenangFiles = dir(fullfile(FOLDER_PATH, 'Senang_*.csv'));

% Tentukan jumlah baris berdasarkan jumlah maksimum file
rows = max(length(NetralFiles), length(SenangFiles));

% Buat figure utama
f = figure('Name', 'Visualisasi Raw EEG Data Training (Netral vs Senang)', ...
           'Position', [100, 100, 1200, 800]);

% Buat layout 2 kolom (kiri: Netral, kanan: Senang)
tiledlayout(rows, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

% ---------- Plot Data Netral (Kolom Kiri) ----------
for i = 1:length(NetralFiles)
    currentFile = NetralFiles(i);
    filePath = fullfile(currentFile.folder, currentFile.name);
    
    try
        T = readtable(filePath);

        % Gunakan eegRawValueVolts dan ubah ke mikrovolt (µV)
        if ismember('eegRawValueVolts', T.Properties.VariableNames)
            RawEEG = T.eegRawValueVolts * 1e6;  % konversi ke µV
        else
            RawEEG = T{:,1} * 1e6;  % fallback jika kolomnya beda
        end

        % Ambil segmen data sesuai durasi
        if length(RawEEG) < SAMPLE_COUNT
            dataSegment = RawEEG;
        else
            dataSegment = RawEEG(1:SAMPLE_COUNT);
        end
        
        timeVector = (0:length(dataSegment)-1) / Fs;

        % Netral ada di kolom 1 → tile indeks ganjil
        tileIndex = (i-1)*2 + 1;
        nexttile(tileIndex);
        plot(timeVector, dataSegment, 'b', 'LineWidth', 0.5);
        ylim([-200 200]);

        title(sprintf('Netral %d', i));
        xlabel('Waktu (s)');
        ylabel('Amplitudo (µV)');
        grid on;

    catch
        nexttile(tileIndex);
        text(0.5, 0.5, 'Error Memuat Data', 'HorizontalAlignment', 'center', 'Color', 'r');
        title(currentFile.name);
    end
end

% ---------- Plot Data Senang (Kolom Kanan) ----------
for i = 1:length(SenangFiles)
    currentFile = SenangFiles(i);
    filePath = fullfile(currentFile.folder, currentFile.name);
    
    try
        T = readtable(filePath);

        % Gunakan eegRawValueVolts dan ubah ke mikrovolt (µV)
        if ismember('eegRawValueVolts', T.Properties.VariableNames)
            RawEEG = T.eegRawValueVolts * 1e6;  % konversi ke µV
        else
            RawEEG = T{:,1} * 1e6;  % fallback jika kolomnya beda
        end

        % Ambil segmen data sesuai durasi
        if length(RawEEG) < SAMPLE_COUNT
            dataSegment = RawEEG;
        else
            dataSegment = RawEEG(1:SAMPLE_COUNT);
        end
        
        timeVector = (0:length(dataSegment)-1) / Fs;

        % Senang ada di kolom 2 → tile indeks genap
        tileIndex = (i-1)*2 + 2;
        nexttile(tileIndex);
        plot(timeVector, dataSegment, 'g', 'LineWidth', 0.5);
        ylim([-200 200]);

        title(sprintf('Senang %d', i));
        xlabel('Waktu (s)');
        ylabel('Amplitudo (µV)');
        grid on;

    catch
        nexttile(tileIndex);
        text(0.5, 0.5, 'Error Memuat Data', 'HorizontalAlignment', 'center', 'Color', 'r');
        title(currentFile.name);
    end
end
