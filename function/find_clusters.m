function [clust_membership, n_clust]=find_clusters(pscores, pthresh, chanhood)
[chanN, timeN]=size(pscores);
[timeMatrix, chanMatrix] = meshgrid(1:timeN, 1:chanN);
above_thresh_ids = find(pscores<=pthresh);
above_thresh_times = timeMatrix(above_thresh_ids);
above_thresh_chans = chanMatrix(above_thresh_ids);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_above=length(above_thresh_ids);
n_clust=0;
global clust_ids; % matrix indicated which cluster each "voxel" belongs to
clust_ids=zeros(chanN, timeN);
for a=1:n_above
    voxel_id=above_thresh_ids(a);
    if ~clust_ids(voxel_id)
        %this "voxel" isn't in a cluster yet
        n_clust=n_clust+1;
        clust_ids(voxel_id)=n_clust;
        %go through all the remaining voxels and find all the above
        %threshold voxels this voxel is neighbors with and give them this
        %cluster #
        voxels_not_checked = ones(size(above_thresh_ids));
        check_me = zeros(size(above_thresh_ids));
        check_me(a) = 1;
        while sum(check_me>0)
            first = find(check_me,1);
            new = follow_clust(n_above,first,n_clust,above_thresh_ids,above_thresh_times,above_thresh_chans,chanhood,chanN);
            check_me(new)=1;
            voxels_not_checked(first)=0;
            check_me = check_me&voxels_not_checked;
        end
    end
end
clust_membership=clust_ids;
clear global clust_ids
    function [new_members] = follow_clust(n_above,current_voxel_id,current_clust_num,above_thresh_ids,above_thresh_times,above_thresh_chans,chan_hood,n_chan)
        %Function for finding all the members of cluster based on
        %single "voxel" seed. If it finds new members of a cluster, it indicates
        %which cluster they are a member of in the global variable clust_ids.
        %
        % Inputs:
        %   clust_ids          - Matrix indicating which cluster each
        %                        voxel belongs to (if any)
        %   n_above            - The total number of above threshold voxels
        %   current_voxel_id   - The index of the seed voxel into
        %                      above_thresh_ids, above_thresh_chans, above_thresh_times
        %   current_clust_num  - The # of the cluster the seed voxel belongs to
        %   above_thresh_ids   - A vector of indices of all the above threshold
        %                      voxels into the original 2d data matrix (channel x
        %                      time point)
        %   above_thresh_times - The time points corresponding to above_thresh_ids
        %   above_thresh_chans - The time points corresponding to above_thresh_chans
        %   neighbourhood      - A symmetric 2d matrix indicating which channels are
        %                      neighbors with other channels.  If chan_hood(a,b)=1,
        %                      then Channel A and B are neighbors.
        %   n_chan             - The total number of channels
        %
        %
        % Output:
        %  new_members - above_thresh_ids indices to new members of the cluster
        
        %   global clust_ids; % channel x time point matrix indicated which cluster each "voxel" belongs to
        
        new_members=zeros(1,n_chan*3); %pre-allocate memory
        new_members_ct=0;
        
        for b=current_clust_num:n_above,
            if ~clust_ids(above_thresh_ids(b))
                temp_dist=abs(above_thresh_times(b)-above_thresh_times(current_voxel_id));
                if above_thresh_chans(current_voxel_id)==above_thresh_chans(b)
                    %voxels are at same channel
                    chan_dist=0;
                elseif chan_hood(above_thresh_chans(current_voxel_id),above_thresh_chans(b))
                    %channels are neighbors
                    chan_dist=1;
                else
                    %voxels aren't spatially compatible
                    chan_dist=2;
                end
                if (temp_dist+chan_dist)<=1,
                    %if voxels are at same time point and neighboring channels OR
                    %if voxels are at same channel and neighboring time points,
                    %merge them into the same cluster
                    
                    clust_ids(above_thresh_ids(b))=current_clust_num;
                    %keep track of which other voxels are joined to this
                    %cluster
                    new_members_ct=new_members_ct+1;
                    new_members(new_members_ct)=b;
                end
            end
        end
        
        new_members=nonzeros(new_members);
    end
end