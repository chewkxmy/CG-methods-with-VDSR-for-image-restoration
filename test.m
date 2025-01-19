% Load and get sizes of images
a = size(imread('pcb1.png'));
b = size(imread('pcb2.bmp'));
c = size(imread('pcb3.jpg'));
d = size(imread('pcb4.jpg'));
e = size(imread('pcb5.png'));
f = size(imread('pcb6.png'));

% Print sizes and total pixel count
fprintf('Size of pcb1.png: %dx%d = %d pixels\n', a(1), a(2), a(1) * a(2));
fprintf('Size of pcb2.bmp: %dx%d = %d pixels\n', b(1), b(2), b(1) * b(2));
fprintf('Size of pcb3.jpg: %dx%d = %d pixels\n', c(1), c(2), c(1) * c(2));
fprintf('Size of pcb4.jpg: %dx%d = %d pixels\n', d(1), d(2), d(1) * d(2));
fprintf('Size of pcb5.png: %dx%d = %d pixels\n', e(1), e(2), e(1) * e(2));
fprintf('Size of pcb6.png: %dx%d = %d pixels\n', f(1), f(2), f(1) * f(2));
