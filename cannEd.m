
function output = cannyEd(A)
if size(A,3)>1
    A = rgb2gray(A);
end

if mod(size( A ,1),2)~=0
     A  =  A (1:size( A ,1)-1,:);
end
if mod(size(A,2),2)~=0
     A  =  A (:,1:size( A ,2)-1);
end

%% 1) Pre-process: Improve contrast then Use wavelets to stregnthen edges
 A  = imadjust( A ); % Imrpove Contrast

% Use wavelets to imrpove edge quality
[cA cH cV cD] = swt2( A ,1,'haar');

% Amplify the wavelet-subbands
cA = 4.*cA; 
cH = 25.*cH;
cV = 25.*cV;
cD = 10.*cD;
A  = mat2gray(iswt2(cA, cH, cV, cD, 'haar'));

%% 2) Compute Derivative of gaussian
sigma = 0.8;
Gx = fspecial('gaussian',[5 5], sigma); % Kernel
Gy = Gx';
delx = [1 -1];
dely = delx';
Jx = conv2(conv2(conv2(A,Gx,'same'),delx,'same'),Gy,'same');
Jy = conv2(conv2(conv2(A,Gy,'same'),dely,'same'),Gx,'same');
DelI = sqrt(Jx.*Jx+Jy.*Jy);
theta = atan2(Jx,Jy);
theta1 = atand(theta); % Calculation of the edge orientation
[r,c]=size( A );
output = zeros(r,c);
LT = 1.5;                   
HT = 3.0;
lowT  = LT.*mean(DelI(:)); % Hysterisis Low and High Thresholds
highT = HT.*lowT;

%% #) Non-Maxima Suppression
for i=1:r,
    for j=1:c,
        if(theta1(i,j)<0)
            theta1(i,j)= theta1(i,j)+360; % Converting angles to positive
        end
    end
end

for i=2:r-1,
    for j=2:c-1,
        if((theta1(i,j) >=0 && theta1(i,j) <= 45) || (theta1(i,j) >=180 && theta1(i,j) <= 225)  )
            if(DelI(i,j) > max(DelI(i-1,j+1),DelI(i+1,j-1)))
                output(i,j) = 1;
            end
        end
        if((theta1(i,j) >=45 && theta1(i,j) <= 90) || (theta1(i,j) >=225 && theta1(i,j) <= 270)  )
            if(DelI(i,j) > max(DelI(i-1,j),DelI(i+1,j)))
                output(i,j) = 1;
            end
        end
        if((theta1(i,j) >=90 && theta1(i,j) <= 135) || (theta1(i,j) >=270 && theta1(i,j) <= 315)  )
            if(DelI(i,j) > max(DelI(i-1,j-1),DelI(i+1,j+1)))
                output(i,j) = 1;
            end
        end
        if((theta1(i,j) >=135 && theta1(i,j) <= 180) || (theta1(i,j) >=315 && theta1(i,j) <= 360)  )
            if(DelI(i,j) > max(DelI(i,j-1),DelI(i,j+1)))
                output(i,j) = 1;
            end
        end
    end
end


%% Step (d) Hysterisis
Val = 0.9;
output = output.*Val;


for i=2:r-1,
    for j=2:c-1,
        if((output(i,j) > 0) && (DelI(i,j) < lowT))
            output(i,j) = 0;
        elseif((output(i,j) > 0) && (DelI(i,j) >= highT))
            output(i,j) = 1;
        end
    end
end

x1 = [];
x = find(output==1);
while (size(x1,1) ~= size(x,1))
    x1 = x;
    v = [x+r+1, x+r, x+r-1, x-1, x-r-1, x-r, x-r+1, x+1];
    output(v) = (1-Val) + output(v);   % Hysterisis
    y = find(output==(1-Val));
    output(y) = 0;
    y = find(output>=1);
    output(y) = 1;
    x = find(output==1);   
end

for i=2:r-1,
    for j=2:c-1,
        if(output(i,j) < 1 && output(i,j) > 0)
            output(i,j) = 1;   % strengthening all the light edges
        end
    end
end

% Displaying the output
imshow(output);

end
