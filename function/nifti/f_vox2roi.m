function newROIimage = f_vox2roi(vox_coor, radius, voxunit, imageMat)
    radius = radius/voxunit;% unit
    newROIvalue = 1;
    xlist = vox_coor(1)-ceil(2*radius):vox_coor(1)+ceil(2*radius);
    xlist(xlist<0) = []; xlist(xlist>size(imageMat, 1)) = [];
    ylist = vox_coor(2)-ceil(2*radius):vox_coor(2)+ceil(2*radius);
    ylist(ylist<0) = []; ylist(ylist>size(imageMat, 2)) = [];
    zlist = vox_coor(3)-ceil(2*radius):vox_coor(3)+ceil(2*radius);
    zlist(zlist<0) = []; zlist(zlist>size(imageMat, 3)) = [];
    [xMesh, yMesh, zMesh] = meshgrid(xlist, ylist, zlist);
    xMesh = xMesh(:);
    yMesh = yMesh(:);
    zMesh = zMesh(:);
    D = sqrt((vox_coor(1)-xMesh).^2+(vox_coor(2)-yMesh).^2+(vox_coor(3)-zMesh).^2);
    index = find(D<=radius);
    newROIimage = zeros(size(imageMat));
    for iN = 1:length(index)
        newROIimage(xMesh(index(iN)), yMesh(index(iN)), zMesh(index(iN))) = newROIvalue;
    end
end