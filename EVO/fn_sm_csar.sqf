[{
	currentSideMission = "csar";
	publicVariable "currentSideMission";
	currentSideMissionStatus = "ip";
	publicVariable "currentSideMissionStatus";

	if (isServer) then {
         	//server
         	opforUnits = [];
         	_vehClass = ["CUP_B_AH1Z", "CUP_B_AH6J_MP_USA", "CUP_B_MH6J_USA", "CUP_B_UH60L_US"] call bis_fnc_selectRandom;
			_veh = createVehicle [_vehClass, csarLoc];
         	_veh setDamage 1;
         	_maxPositions = (_veh emptyPositions "Commander") + (_veh emptyPositions "Gunner") + (_veh emptyPositions "Driver");
         	csarGrp = createGroup west;
         	csarLoc = getPos _veh;
         	_class = ["B_Helipilot_F","B_helicrew_F"] call bis_fnc_selectRandom;
         	_unit = csarGrp createUnit [_class, getPos _veh, [], 0, "FORM"];
         	[_unit] spawn {
         	 	_this select 0 allowDamage false;
         	 	sleep 10;
         	 	_this select 0 allowDamage true;
         	};
         	for "_i" from 1 to (_maxPositions - 1) step 1 do {
         	    if ([true, false] call bis_fnc_selectRandom) then {
         	    	_unit = csarGrp createUnit ["CUP_B_US_Pilot_Light", getPos _veh, [], 0, "FORM"];
         	    	[_unit] spawn {
         	    		_this select 0 allowDamage false;
         	    		sleep 10;
         	    		_this select 0 allowDamage true;
         	    		_this select 0 setCaptive true;
         	    	};
         	    };
         	};
         	csarUnits = units csarGrp;
         	{
         		_x addAction [format["Rescue %1", name _x],"[_this select 0] join _this select 1; _this select 0 setCaptive false;",nil,1,false,true,"","group _x == csarGrp"];
         	} forEach csarUnits;
		for "_i" from 1 to (["Infantry", "Side"] call EVO_fnc_calculateOPFOR) do {
			_spawnPos = [locationPosition csarLoc, 1000, 1500, 10, 0, 2, 0] call BIS_fnc_findSafePos;
			_grp = [_spawnPos, EAST, (configFile >> "CfgGroups" >> "EAST" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad")] call EVO_fnc_spawnGroup;
			if (HCconnected) then {
				{
					handle = [_x] call EVO_fnc_sendToHC;
				} forEach units _grp;
			};
			{

				opforUnits = opforUnits + [_x];
			}  forEach units _grp;
			handle = [_grp, csarLoc] call BIS_fnc_taskAttack;
		};

		handle = [] spawn {
			waitUntil {{_x distance spawnBuilding < 50} count csarUnits == {alive _x} count csarUnits || {alive _x} count csarUnits < 1};
			sleep (random 15);
			if ({alive _x} count units reinforceSquad > 0) then {
				currentSideMissionStatus = "success";
				publicVariable "currentSideMissionStatus";
				[csarTask, "Succeeded", false] call bis_fnc_taskSetState;
			} else {
				currentSideMissionStatus = "failed";
				publicVariable "currentSideMissionStatus";
				[csarTask, "Failed", false] call bis_fnc_taskSetState;
			};
			currentSideMission = "none";
			publicVariable "currentSideMission";
			 [] spawn EVO_fnc_pickSideMission;
			{
				deleteVehicle _x;
			} forEach opforUnits;
		};
		_tskDisplayName = format ["Rescue NATO Helo Crew"];
		csarTask = format ["csarTask%1", floor(random(1000))];
		[WEST, [csarTask], [_tskDisplayName, _tskDisplayName, ""], (getMarkerPos csarMarker), 1, 2, true] call BIS_fnc_taskCreate;
	};
	if (!isDedicated) then {
	//client
		CROSSROADS sideChat "Any available units, we have a helo down! Conduct CSAR ASAP.";
		["TaskAssigned",["","Rescue Helo Crew"]] call BIS_fnc_showNotification;
		handle = [] spawn {
			waitUntil {currentSideMissionStatus != "ip"};
			if (currentSideMissionStatus == "success") then {
				if (player distance spawnBuilding < 1000) then {
					playsound "goodjob";
					[player, 10] call BIS_fnc_addScore;
					["PointsAdded",["You completed a sidemission.", 10]] call BIS_fnc_showNotification;
				};
				sleep (random 15);
				CROSSROADS sideChat "Our downed crew made it home safely. Nice job men!";
				["TaskSucceeded",["","Helo Crew Survived"]] call BIS_fnc_showNotification;
			} else {
				CROSSROADS sideChat "We've lost communications with our downed crew, all units RTB and rearm.";
				["TaskFailed",["","Helo Crew KIA"]] call BIS_fnc_showNotification;
			};
			currentSideMission = "none";
			publicVariable "currentSideMission";
		};
	};
},"BIS_fnc_spawn",true,true] call BIS_fnc_MP;
