function compare_two_forms(image_path1, image_path2)
    % İlk formu işle
    [centers1, radii1, img1] = detect_and_sort_circles(image_path1);
    % İkinci formu işle
    [centers2, radii2, img2] = detect_and_sort_circles(image_path2);

    % Şekli oluştur
    figure;

    % 1. Formu göster
    subplot(2,1,1);
    imshow(img1); hold on;
    viscircles(centers1, radii1, 'EdgeColor', 'r');
    for i = 1:size(centers1,1)
        text(centers1(i,1), centers1(i,2), num2str(i), ...
            'Color', 'yellow', 'FontSize', 6, 'FontWeight', 'bold');
    end
    title('Form 1: Cevap Anahtarı');

    % 2. Formu göster
    subplot(2,1,2);
    imshow(img2); hold on;
    viscircles(centers2, radii2, 'EdgeColor', 'r');
    for i = 1:size(centers2,1)
        text(centers2(i,1), centers2(i,2), num2str(i), ...
            'Color', 'yellow', 'FontSize', 6, 'FontWeight', 'bold');
    end
    title('Form 2: Öğrenci Formu');
end
