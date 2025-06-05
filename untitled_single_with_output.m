function siyah_daireler = untitled_single_with_output(image_path)
    img = imread(image_path);
    if size(img,3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end

    img_gray = adapthisteq(img_gray);
    img_gray = medfilt2(img_gray, [3 3]);

    [centers, radii, metric] = imfindcircles(img_gray, [8 50], ...
        'ObjectPolarity','dark', ...
        'Sensitivity',0.97, ...
        'EdgeThreshold',0.05);

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

    % Daireleri sütun sütun grupla
    threshold_x = 10;
    sorted_centers = centers;
    groups = {};

    while ~isempty(sorted_centers)
        base = sorted_centers(1,:);
        col_inds = abs(sorted_centers(:,1) - base(1)) < threshold_x;
        col_group = sorted_centers(col_inds,:);
        col_group = sortrows(col_group, 2); 
        groups{end+1} = col_group;
        sorted_centers(col_inds,:) = [];
    end

    group_x = cellfun(@(g) mean(g(:,1)), groups);
    [~, idx] = sort(group_x, 'ascend');
    groups_sorted = groups(idx);

    sorted_centers_final = vertcat(groups_sorted{:});
    sorted_radii_final = radii(1:size(sorted_centers_final,1));

    % Siyah daireleri tespit et
    siyah_daireler = [];

    for i = 1:size(sorted_centers_final,1)
        x = round(sorted_centers_final(i,1));
        y = round(sorted_centers_final(i,2));
        r = round(sorted_radii_final(i)) - 2;

        y1 = max(1, y-r); y2 = min(size(img_gray,1), y+r);
        x1 = max(1, x-r); x2 = min(size(img_gray,2), x+r);
        bolge = img_gray(y1:y2, x1:x2);

        ortalama_intensite = mean(bolge(:));

        if ortalama_intensite < 80
            siyah_daireler(end+1) = i;
        end
    end
end
