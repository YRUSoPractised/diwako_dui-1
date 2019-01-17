#include "../script_component.hpp"
if (is3DEN || !hasInterface) exitWith {};
params [["_display", displayNull]];
if !(diwako_dui_enable_compass) exitWith {};

if (isNull _display) then {
    _display = uiNamespace getVariable "diwako_dui_RscCompass";
};

if (isNull _display) exitWith {systemChat "No Display"};

private _ctrlGrp = _display displayCtrl IDC_COMPASS_CTRLGRP;
private _compass = _display displayCtrl IDC_COMPASS;
private _dirCtrl = _display displayCtrl IDC_DIRECTION;
diwako_dui_compass_pfHandle = [{
    params ["_args", "_pfhHandle"];
    _args params ["_display", "_compassCtrl", "_dirCtrl", "_ctrlGrp"];

    if !(diwako_dui_enable_compass) exitWith {
        [_pfhHandle] call CBA_fnc_removePerFrameHandler;
        ("diwako_dui_compass" call BIS_fnc_rscLayer) cutText ["","PLAIN"];
        diwako_dui_compass_pfHandle = -1;
    };

    // todo spectator and death
    private _player = [] call CBA_fnc_currentUnit;
    if ([_player] call diwako_dui_fnc_canHudBeShown) then {
        if !(ctrlShown _ctrlGrp) then {
            _ctrlGrp ctrlShow true;
        };
        // private _camDirVec = positionCameratoWorld [0,0,0] vectorFromTo (positionCameraToWorld [0,0,1]);
        // private _dir = _camDirVec call CBA_fnc_vectDir;
        private _dir = (getCameraViewDirection _player) call CBA_fnc_vectDir;
        private _hasCompass = ("ItemCompass" in assignedItems _player);

        _compassCtrl ctrlSetAngle [[0,-_dir] select _hasCompass, 0.5, 0.5, true];
        _compassCtrl ctrlSetTextColor [1, 1, 1, 1];
        _compassCtrl ctrlSetText (diwako_dui_compass_style select _hasCompass);

        if (_hasCompass && {diwako_dui_enable_compass_dir == 2 || {diwako_dui_enable_compass_dir == 1 && {!(isNull objectParent _player)}}}) then {
            _dirCtrl ctrlSetTextColor [1, 1, 1, 1];
            _dirCtrl ctrlSetFont diwako_dui_font;
            if (diwako_dui_dir_showMildot) then {
                _dirCtrl ctrlSetText format ["%1 %2", (round _dir) mod 360, round (_dir / 0.056250)];
            } else {
                _dirCtrl ctrlSetText format ["%1", (round _dir) mod 360];
            };
        } else {
            _dirCtrl ctrlSetText "";
        };


        private _usedCtrls = [];
        private _ctrls = _ctrlGrp getVariable ["diwako_dui_ctrlArr",[]];
        private _playerDir = getDir _player;

        {
            _usedCtrls pushBack ([_x, _display, _dir, _playerDir, _player, _ctrlGrp] call diwako_dui_fnc_displayUnitOnCompass);
        } forEach diwako_dui_group;

        private _unusedCtrls = _ctrls - _usedCtrls;
        {
            ctrlDelete _x;
        } forEach _unusedCtrls;

        (_display displayCtrl IDC_COMPASS_CTRLGRP) setVariable ["diwako_dui_ctrlArr",_usedCtrls];

        if !(isNil "diwako_dui_custom_code") then {
            /*
                Keep in mind this runs EVERY FRAME!
                1. Display of the RscTile
                2. Control of the compass
                3. Control of the bearing indicator
                4. Control group of the units displayed on the compass
                5. All currently shown unit icons on the compass
            */
            [_display, _compass, _dirCtrl, _ctrlGrp, _usedCtrls] call diwako_dui_custom_code;
        };
    } else {
        _compassCtrl ctrlSetTextColor [1, 1, 1, 0];
        _dirCtrl ctrlSetTextColor [1, 1, 1, 0];

        _ctrlGrp ctrlShow false;
    };
}, diwako_dui_compassRefreshrate, [_display, _compass, _dirCtrl, _ctrlGrp] ] call CBA_fnc_addPerFrameHandler;
