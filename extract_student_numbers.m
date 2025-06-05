function student_number = extract_student_numbers(image_path, show_figure)
    if nargin < 2
        show_figure = false; 
    end

    % Resmi oku ve griye çevir
    img = imread(image_path);
    if size(img,3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end

    % Görüntüyü iyileştir
    img_gray = adapthisteq(img_gray);
    img_gray = medfilt2(img_gray, [3 3]);

    % Daireleri bul
    [centers, radii, metric] = imfindcircles(img_gray, [8 50], ...
        'ObjectPolarity','dark', 'Sensitivity',0.97, 'EdgeThreshold',0.05);

    % Çok yakın daireleri filtrele
    minDist = 15;
    keep = true(size(centers,1),1);
    for i = 1:size(centers,1)
        for j = i+1:size(centers,1)
            if keep(j) && norm(centers(i,:) - centers(j,:)) < minDist
                if metric(i) > metric(j)
                    keep(j) = false;
                else
                    keep(i) = false;
                end
            end
        end
    end
    centers = centers(keep,:);
    radii = radii(keep);

    % En fazla 90 daireyi al 
    maxCount = 90;
    if size(centers,1) > maxCount
        centers = centers(1:maxCount,:);
        radii = radii(1:maxCount);
    end

    % Sütun sütun, yukarıdan aşağı sıralama 
    sorted_centers = sort_circles_by_column(centers);

    % Sadece ilk 40 daireyi kullan (4 hane * 10 rakam)
    if size(sorted_centers,1) < 40
        error('Yeterli daire bulunamadı!');
    end
    sorted_centers_40 = sorted_centers(1:40,:);
    radii_40 = radii(1:40);

    % 4 grup halinde işle
    student_number_digits = zeros(1,4);
    for hane = 1:4
        idx_start = (hane-1)*10 + 1;
        idx_end = hane*10;
        group_centers = sorted_centers_40(idx_start:idx_end,:);
        group_radii = radii_40(idx_start:idx_end);

        % Her daire için işaret kontrolü (dairenin içindeki piksel ortalaması)
        avg_intensity = zeros(10,1);
        for k = 1:10
            c = group_centers(k,:);
            r = group_radii(k);
            % Dairenin etrafındaki bir kutu çıkar
            x_min = max(round(c(1)-r),1);
            x_max = min(round(c(1)+r), size(img_gray,2));
            y_min = max(round(c(2)-r),1);
            y_max = min(round(c(2)+r), size(img_gray,1));
            circle_region = img_gray(y_min:y_max, x_min:x_max);

            % Dairenin merkezine göre mask oluştur
            [X, Y] = meshgrid(x_min:x_max, y_min:y_max);
            dist_from_center = sqrt((X - c(1)).^2 + (Y - c(2)).^2);
            mask = dist_from_center <= r;

            % Maskeli bölgedeki ortalama gri yoğunluğu
            avg_intensity(k) = mean(double(circle_region(mask)));
        end

        % En koyu daire işaretli
        [~, idx_black] = min(avg_intensity);

        % İşaretli daire 1-10 arası index, rakam olarak 0-9'a dönüştür
        student_number_digits(hane) = idx_black - 1; % 1->0, 2->1, ..., 10->9
    end

    % öğrenci numarası
    student_number = sprintf('%04d', str2double(strjoin(string(student_number_digits),'')));
    %disp(['Öğrenci Numarası: ', student_number]);

    % Görselleştirme 
    if show_figure
        figure;
        imshow(img); hold on;
        viscircles(sorted_centers_40, radii_40, 'EdgeColor', 'r');
        for i=1:40
            text(sorted_centers_40(i,1), sorted_centers_40(i,2), num2str(i), ...
                'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
        end
        hold off;
    end
end


function sorted_centers = sort_circles_by_column(centers)
    % Burada sütun sütun, yukarıdan aşağı sıralama yapılacak

    tol_x = 15; % Sütun farkı toleransı 
    centers = sortrows(centers,1); % x'e göre sırala 
    columns = {};
    while ~isempty(centers)
        base_x = centers(1,1);
        col_inds = abs(centers(:,1) - base_x) < tol_x;
        col_group = centers(col_inds,:);
        col_group = sortrows(col_group,2); % y'ye göre sırala 
        columns{end+1} = col_group;
        centers(col_inds,:) = [];
    end
    % Sütunları yan yana koy
    sorted_centers = vertcat(columns{:});
end
