function data=preprocessStudentData(unmasked_pixels)
	data = [];
	filenames = ls('../StudentDatabase');
	if size(filenames, 1) == 1 %unix computer
        filenames = getAllFiles('../StudentDatabase');
	end
	for i=1:size(filenames, 1)
		filename = strtrim(char(filenames(i,:)));
		if size(filename,2) > 4 && isequal(filename(size(filename,2)-3: size(filename,2)), '.jpg')
			path = strcat('../StudentDatabase/', filename);
			colorimg = imread(path);
			grayscaleimg = rgb2gray(colorimg);
			im_vector = grayscaleimg(unmasked_pixels);
			data(size(data,1)+1,:) = im_vector';
		end
	end