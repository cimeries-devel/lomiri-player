/*
 * Copyright (C) 2013, 2014, 2015
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Daniel Holm <d.holmen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Lomiri.Components 1.3


QtObject {
    property QtObject addtoPlaylist: QtObject {
        property color backgroundColor: theme.palette.normal.background;
        property color labelColor: common.black;
        property color labelSecondaryColor: theme.palette.normal.backgroundSecondaryText;
        property color progressBackgroundColor: theme.palette.normal.background;
        property color progressForegroundColor: theme.palette.normal.focus;
        property color progressHandleColor: theme.palette.normal.foregroundText;
    }

    property QtObject common: QtObject {
        property color black: "#000000";
        property color white: "#FFFFFF";
        property color music: theme.palette.normal.foregroundText;
        property color subtitle: theme.palette.normal.backgroundSecondaryText;
        property color expandedColor: "#000000"; //unused
        property int albumSize: units.gu(10);
        property int itemHeight: units.gu(12);
        property int expandHeight: units.gu(7);
        property int expandedItem: units.gu(2);
        property int expandedTopMargin: units.gu(13.5);
        property int expandedLeftMargin: units.gu(2);
    }

    property QtObject dialog: QtObject {
        property color confirmButtonColor: theme.palette.normal.positive;
        property color confirmRemoveButtonColor: theme.palette.normal.negative;
        property color cancelButtonColor: theme.name == "Lomiri.Components.Themes.Ambiance" ? LomiriColors.ash : LomiriColors.graphite;
        property color normalTextFieldColor: common.white;
    }

    property QtObject libraryEmpty: QtObject {
        property color backgroundColor: theme.palette.normal.background;
        property color labelColor: theme.palette.normal.backgroundText;
    }

    property QtObject listView: QtObject {
        property color highlightColor: common.white;
    }

    property QtObject mainView: QtObject{
        property color backgroundColor: theme.palette.normal.background
        property color footerColor: backgroundColor
        property color headerColor: backgroundColor
    }

    property QtObject nowPlaying: QtObject {
        property color backgroundColor: theme.palette.normal.background;
        property color foregroundColor: theme.palette.normal.backgroundSecondaryText
        property color labelColor: theme.palette.normal.backgroundText;
        property color labelSecondaryColor: theme.palette.normal.backgroundSecondaryText;
        property color progressBackgroundColor: theme.palette.normal.background;
        property color progressForegroundColor: theme.palette.normal.focus;
        property color progressHandleColor: common.white;
    }

    property QtObject playerControls: QtObject {
        property color backgroundColor: "#0f0f0f";
        property color labelColor: theme.palette.normal.backgroundText;
        property color progressBackgroundColor: theme.palette.normal.background;
        property color progressForegroundColor: theme.palette.normal.focus;
    }

    property QtObject popover: QtObject {
        property color labelColor: theme.palette.normal.foreground;
    }

    property QtObject playlist: QtObject {
        property int infoHeight: units.gu(14);
        property int playlistItemHeight: units.gu(10);
        property int playlistAlbumSize: units.gu(8);
    }

    property QtObject toolbar: QtObject {
        property color fullBackgroundColor: theme.palette.normal.background;
        property color fullInnerPlayCircleColor: "#0d0d0d"; //unused
        property color fullOuterPlayCircleColor: "#363636"; //unused
        property color fullProgressBackgroundColor: "#252525"; //unused
        property color fullProgressTroughColor: theme.palette.normal.activity;
    }

    property QtObject albums: QtObject {
        property int itemHeight: units.gu(4);
    }

    property QtObject artists: QtObject {
        property int itemHeight: units.gu(12.5);
    }

    Component.onCompleted: Theme.palette.normal.field=styleMusic.dialog.normalTextFieldColor
}
