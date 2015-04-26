/*
_missionsData 	= [
		[getMarkerPos "m1",start_mission01,"<Text to Display>","<Description>","","<image>",1,[]],
		[getMarkerPos "m2",start_mission02,"<Text to Display>","<Description>","","<image>",1,[]]
];
*/
currentSideMission = "none";
//build AA hunt
//as long as there are AAA batteries
_options = [];
{
	_vehicle = _x;
	if (typeOf _vehicle == "O_APC_Tracked_02_AA_F" && alive _vehicle && canMove _vehicle) then {
		_options = _options + [_vehicle];
	};
} forEach vehicles;
_vehicle = _options call BIS_fnc_selectRandom;
if (!isNil "_vehicle") then {
	aaHuntTarget = _vehicle;
	publicVariable "aaHuntTarget";
	_img = getText(configFile >>  "CfgVehicles" >>  (typeOf _vehicle) >> "picture");
	availableSideMissions = availableSideMissions + [
		[getPos aaHuntTarget, EVO_fnc_sm_aaHunt,"Destroy AAA Battery","Eliminate the OPFOR anti-air threat to enable BLUFOR support to continue.","", _img, 1,[]]
	];
};

//base defence
// 1 in 4 chance
_bool = [true, false, false, false] call BIS_fnc_selectRandom;
//_bool = true;
if (_bool) then {
	_img = getText(configFile >>  "CfgTaskTypes" >>  "Defend" >> "icon");
	availableSideMissions = availableSideMissions + [
		[getPos spawnBuilding, EVO_fnc_sm_baseDef,"Defend NATO Staging Base","OPFOR ground units are converging on the staging base. Defeat the enemy counterattack.","",_img,1,[]]
	];
};


//military installation
// 1 in 2 chance
_bool = [true, false] call BIS_fnc_selectRandom;
//_bool = true;
if (_bool) then {
	attackMilTarget = militaryLocations call BIS_fnc_selectRandom;
	_pos = position attackMilTarget;
	_array = nearestObjects [_pos, ["house"], 200];
	_obj = _array select 0;
	_img = getText(configFile >>  "CfgTaskTypes" >>  "Attack" >> "icon");
	availableSideMissions = availableSideMissions + [
		[getPos _obj, EVO_fnc_sm_attackMil,"Attack Installation","We discovered an OPFOR installation with fortified defences. Seize it to weaken their foothold.","",_img,1,[]]
	];
};

//military installation
// 1 in 2 chance
//_bool = [true, false] call BIS_fnc_selectRandom;
_bool = true;
if (_bool) then {
	_locationArray = militaryLocations + targetLocations;
	convoyStart = _locationArray call BIS_fnc_selectRandom;
	_locationArray = nearestLocations [ (position convoyStart), ["NameCity", "NameCityCapital","NameVillage"], 10000];
	convoyEnd = _locationArray call BIS_fnc_selectRandom;
	_pos = position convoyStart;
	_array = nearestObjects [_pos, ["house"], 200];
	_obj = _array select 0;
	_img = getText(configFile >>  "CfgTaskTypes" >>  "Destroy" >> "icon");
	availableSideMissions = availableSideMissions + [
		[getPos _obj, EVO_fnc_sm_convoy,"Ambush Convoy","We have received intel that an OPFOR convoy with supplies will be departing from here. Ambush them and destroy any supply vehicles.","",_img,1,[]]
	];
};
