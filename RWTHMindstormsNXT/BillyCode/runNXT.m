function [intendedpos] = runNXT (points)
    
    % Beginning point is to get a reference from the starting point as all
    % encoders default to 0 when the NXT is turned on
    beginz = -363.6659;

    % Reorder points via calculation of shortest path at each step. This is
    % essentially djikstra's algorithm in this case because we have every
    % point fully connected to every other point (there is no limit to
    % where we can move from one to another). Because of this, Prim's
    % algorithm also has no computational benefit over djikstra's
    newpoints = primsAlg(points);


    % Connect to NXT and grab the handle
    h =  COM_OpenNXT();
    COM_SetDefaultNXT(h);
    
    % Reset the rotationCounter on the motors
    NXT_ResetMotorPosition(0, false, h);
    NXT_ResetMotorPosition(1, false, h);
    NXT_ResetMotorPosition(2, false, h);


    [m,n] = size(newpoints);
    % Assuming inputs are 1-row arrays of subsequent x,y and z co-ords
    j = 1;
    while j<=m
        % Extract each points co-ordinates from the input
        x = newpoints(j,1);
        y = newpoints(j,2);
        z = newpoints(j,3);
        
        % Run the inverse kinematics for the position of each motor (in
        % degrees)
        degx = inverseKin(x,y,z+beginz,0);
        degy = inverseKin(x,y,z+beginz,120);
        degz = inverseKin(x,y,z+beginz,-120);
        intendedpos = [(degx)*5 (degy)*5 (degz)*5]; % *5 to account for gearing down
        
        % Pass handle to get the current rotation counters of each motor in
        % a 1x3 array
        currentpos = getRTC(h);
        
        % Minus currentpos from intended pos to get the relative movement
        % required
        moveangles = intendedpos - currentpos;
        
        % Run the movement
        runMotor(moveangles);
        
        j= j+3;
    end
    
    
end