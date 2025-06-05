% Cevap anahtarı form yolunu sor
form1_path = input('Cevap anahtarı form yolunu giriniz (çıkmak için q): ', 's');
if strcmpi(form1_path, 'q')
    disp('Program sonlandırıldı.');
    return; 
end

try
    % Anahtardaki siyah dairelerin indekslerini bir kere al
    siyah_form1 = untitled_single_with_output(form1_path);
catch ME
    fprintf('Anahtar dosyası okunurken hata oluştu: %s\n', ME.message);
    return;
end

while true
    % Öğrenci form yolunu sor
    form2_path = input('Öğrenci form yolunu giriniz (çıkmak için q): ', 's');
    if strcmpi(form2_path, 'q')
        disp('Program sonlandırıldı.');
        break;
    end

    try
        % Öğrenci formundaki siyah dairelerin indekslerini al
        siyah_form2 = untitled_single_with_output(form2_path);

        % Sadece soru alanını dikkate al
        aralik = 41:90;
        anahtar = siyah_form1(ismember(siyah_form1, aralik));
        ogrenci = siyah_form2(ismember(siyah_form2, aralik));

        % Doğru eşleşmeler
        dogru = intersect(anahtar, ogrenci);
        dogru_sayisi = length(dogru);

        % Yanlış işaretlenen sorular
        yanlislar = setdiff(ogrenci, anahtar);
        yanlis_sayisi = length(yanlislar);

        % Boş kalan sorular = 10 - cevaplanan soru sayısı
        bos_sayisi = max(0, 10 - length(ogrenci));

        % Öğrenci numarasını oku
        student_number = extract_student_numbers(form2_path);

        % Sonuçları göster
        fprintf('\n=== DEĞERLENDİRME ===\n');
        fprintf('Öğrenci Numarası : %s\t', student_number);
        fprintf('Doğru Sayısı     : %d\t', dogru_sayisi);
        fprintf('Yanlış Sayısı    : %d\t', yanlis_sayisi);
        fprintf('Boş Sayısı       : %d\t\n', bos_sayisi);
    catch ME
        fprintf('Hata oluştu: %s\n', ME.message);
        disp('Lütfen dosya yollarını ve formatlarını kontrol edip tekrar deneyin.');
    end
end
