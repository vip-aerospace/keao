% Resolution approximation model - Payload subsystem

% ==================================================================
% ==================================================================

% plots rectangle on surface of the Earth,
% representing area viewed in a picture by camera on Ke Ao 1U Cubesat
% ==================================================================
% rectangle is rough approximation of actual area viewed
% true shape is drawn outward at corners
% approximation is most true at midpoints of the 4 sides
% ==================================================================
% Included in this model
%   -rotation in pitch direction (seen as vertical shift in plot) > line 49
%   -rotation in yaw direction (seen as horizontal shift in plot) > line 46
%   -rotation in roll direction (seen as rotation orthogonal to surface of
%       Earth) > line 59
%   -shifts in latitudinal/longitudinal coordinates of satellite > line 130
% ==================================================================
% Goals of model
%   -define pointing accuracy needed from ADCS subsystem
%       *limits: include all islands in the picture
%   -validate hand calculations, expectations of shift in area with given
%    error in attitude or position
%   -define conditions of data opportunity
%       *namely lowest acceptable elevation angle for attempting data
%       collection
%       *elevation angle: angle made by observer at target point, viewing horizon, finding angle from horizon to satellite moving upward
%           --> negative angle === satellite is beneath horizon (observer
%           cannot see it)
%           --> 90 degree angle == satellite is directly above observer


% current state
%   -cannot roll and pitch/yaw together
%   -cannot roll properly (side lengths are incorrect, but rotated
%   properly)


alt = 400;      % altitude of the orbit
h = 94.91;      % horizontal field of view [degrees]
v = 68.46;      % vertical field of view [degrees]


% rotation in yaw direction
yaw = 5;
hoffrad = pi*yaw/180;
% rotation in pitch direction
pitch = 10;
voffrad = pi*pitch/180;

hrad = pi*h/180;
vrad = pi*v/180;

hrad2 = hrad/2;
vrad2 = vrad/2;

% rotation in yaw direction
roll = 45;
rollrad = pi*roll/180;


% calculate horizontal/vertical distances of each point from center
dh = [alt*tan(hrad2) alt*tan(hrad2) alt*tan(-hrad2) alt*tan(-hrad2)];
dv = [alt*tan(vrad2) alt*tan(-vrad2) alt*tan(-vrad2) alt*tan(vrad2)];


% adjust side lengths if yaw does not equal 0
if yaw ~= 0
    dh = [alt*tan(hrad2+hoffrad) alt*tan(hrad2+hoffrad) alt*tan(-hrad2+hoffrad) alt*tan(-hrad2+hoffrad)];
end
 
% adjust side lengths if pitch does not equal 0
if pitch ~= 0
    dv = [alt*tan(vrad2+voffrad) alt*tan(-vrad2+voffrad) alt*tan(-vrad2+voffrad) alt*tan(vrad2+voffrad)];
end

ddh = [0 0 0 0];
ddv = [0 0 0 0];



delta = [atan(dv(1)/dh(1))
    atan(dh(2)/dv(2))
    atan(dv(3)/dh(3))
    atan(dh(4)/dv(4))]


% adjust sides if roll does not equal 0
% !!! work-in-progress
ddh(1) = sqrt(dh(1)^2+dv(1)^2)*cos(atan(dv(1)/dh(1))-rollrad);
ddh(2) = sqrt(dh(2)^2+dv(2)^2)*sin(atan(dh(2)/dv(2))+rollrad);
ddh(3) = -sqrt(dh(3)^2+dv(3)^2)*cos(atan(dv(3)/dh(3))-rollrad);
ddh(4) = -sqrt(dh(4)^2+dv(4)^2)*sin(atan(dh(4)/dv(4))+rollrad)

ddv(1) = sqrt(dh(1)^2+dv(1)^2)*sin(atan(dv(1)/dh(1))-rollrad);
ddv(2) = sqrt(dh(2)^2+dv(2)^2)*cos(atan(dh(2)/dv(2))+rollrad);
ddv(3) = -sqrt(dh(3)^2+dv(3)^2)*sin(atan(dv(3)/dh(3))-rollrad);
ddv(4) = -sqrt(dh(4)^2+dv(4)^2)*cos(atan(dh(4)/dv(4))+rollrad)


if roll~=0
    dh = [ddh(1) ddh(2) ddh(3) ddh(4)];
    dv = [ddv(1) ddv(2) ddv(3) ddv(4)];
end

dh
dv

% calculate near-center of islands from cartesian to spherical coordinates
% ---> Only radius of Earth currently used
[phi0,theta0,r0] = cart2sph(-5483.5,-2327.6,2271.4);

% adjust spherical angles for true center of Islands
% caluclated by averaging extremes of South/North/East/Westmost points of
% islands
phi0 = deg2rad(-157.527);
theta0 = deg2rad(20.57);


% sample satellite positions
sat1 = [deg2rad(-158.92) deg2rad(23.283) r0+411.32];    % 53 degree elevation
sat2 = [deg2rad(-156.793) deg2rad(20.868) r0+410.69];   % 81 degree elevation
sat3 = [deg2rad(-155.15) deg2rad(18.913) r0+410.23];    % 52 degree elevation
sat4 = [deg2rad(-154.964) deg2rad(22.905) r0+411.218];  % 50 degree elevation
sat5 = [deg2rad(-159.725) deg2rad(19.605) r0+410.39];   % 55 degree elevation


% define satellite position
sat = sat5;





% angular offsets for azimuthal and elevation angles
% allows plotting of 4 corner points of rectangle
alpha = [atan(dh(1)/r0)
    atan(dh(2)/r0)
    atan(dh(3)/r0)
    atan(dh(4)/r0)];
beta = [atan(dv(1)/r0) 
    atan(dv(2)/r0)
    atan(dv(3)/r0)
    atan(dv(4)/r0)];



% angular calcs (spherical coordinates) for 4 corners of rectangle
phi = [sat(1) + alpha(1) 
    sat(1) + alpha(2) 
    sat(1) + alpha(3) 
    sat(1) + alpha(4)];
theta = [sat(2) + beta(1)
    sat(2) + beta(2) 
    sat(2) + beta(3)
    sat(2) + beta(4)];



% finding center of camera-viewed area (rectangle) for plotting %
area_avg = zeros(1,3);
[area_avg(1) area_avg(2) area_avg(3)] = sph2cart(mean(phi),mean(theta),r0);



% converting spherical coordinates to cartesian
% points for satellite and center of islands (longitudinal/latitudinal
% center)
center = zeros(1,3);
[center(1), center(2), center(3)] = sph2cart(phi0,theta0,r0);
[sat(1), sat(2), sat(3)] = sph2cart(sat(1),sat(2),sat(3));



%vector for pointing from satellite to Earth's center
U = -sat(1);
V = -sat(2);
W = -sat(3);



% variable to hold converted spherical coordinates
% coverted from spherical to cartesian for plotting

X = zeros(4,3);

for i=1:1:4
    [X(i,1), X(i,2), X(i,3)] = sph2cart(phi(i),theta(i),r0+15);
end




% variable for plotting border of rectangle
pts = [X(1,:);X(2,:);X(3,:);X(4,:);X(1,:)];



% test for spherical plotting method 
% test = zeros(1,3);
% 
% test(1) = -(atan(alt*tan(hrad2+hoffrad)/r0) - phi(1));
% test(2) = -(atan(alt*tan(vrad2+voffrad)/r0) - theta(1));
% 
% [test(1) test(2) test(3)] = sph2cart(test(1),test(2),6376);


% model of sphere
% (( GRS80 and WGS84 models have <0.1% difference ))
grs80 = referenceEllipsoid('grs80','km');




figure(1)                      %% prints on figure 1 each time
% figure('Renderer','opengl')  %% prints new figure each time
clf()



% spherical plot
ax = axesm('globe','Geoid',grs80,'Grid','on', ...
    'GLineWidth',1,'GLineStyle','-',...
    'Gcolor',[0.1 0.1 0.1],'Galtitude',100);
ax.Position = [0 0 1 1];
axis equal off
hold on
view(3)


% topographical elements of Earth plot

load topo60c
geoshow(topo60c,topo60cR,'DisplayType','texturemap')
demcmap(topo60c)
land = shaperead('landareas','UseGeoCoords',true);
plotm([land.Lat],[land.Lon],'Color','black')
rivers = shaperead('worldrivers','UseGeoCoords',true);
plotm([rivers.Lat],[rivers.Lon],'Color','blue')



% vectors from satellite to corners, center of pointing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

quiver3(sat(1),sat(2),sat(3),-sat(1)+area_avg(1),-sat(2)+area_avg(2),-sat(3)+area_avg(3),'y')
quiver3(sat(1),sat(2),sat(3),X(1,1)-sat(1),X(1,2)-sat(2),X(1,3)-sat(3),'g')
quiver3(sat(1),sat(2),sat(3),X(2,1)-sat(1),X(2,2)-sat(2),X(2,3)-sat(3),'g')
quiver3(sat(1),sat(2),sat(3),X(3,1)-sat(1),X(3,2)-sat(2),X(3,3)-sat(3),'g')
quiver3(sat(1),sat(2),sat(3),X(4,1)-sat(1),X(4,2)-sat(2),X(4,3)-sat(3),'g')



% latitudinal/longitudinal center of islands

plot3(center(1),center(2),center(3),'r*')



% outline of rectangle

line(pts(:,1), pts(:,2), pts(:,3),'Color','m','LineWidth',2)
plot3(X(:,1),X(:,2),X(:,3),'y*')

% xlabel('x')
% ylabel('y')
% zlabel('z')



