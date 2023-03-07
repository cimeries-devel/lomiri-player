/*
 * Copyright (C) 2014, 2015, 2016
 *      Andrew Hayzen <ahayzen@gmail.com>
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
import "../"


Item {
    id: card
    height: parent.parent.cellHeight
    width: parent.parent.cellWidth

    property alias coverSources: coverGrid.covers
    property alias primaryText: primaryLabel.text
    property alias secondaryText: secondaryLabel.text
    property alias secondaryTextVisible: secondaryLabel.visible

    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    /* Animations */
    Behavior on height {
        NumberAnimation {
            duration: LomiriAnimation.FastDuration
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: LomiriAnimation.FastDuration
        }
    }

    /* Background for card */
    Rectangle {
        id: bg
        anchors {
            fill: parent
            margins: units.gu(1)
        }
        color: "#2c2c34"
    }

    /* Column containing image and labels */
    Column {
        id: cardColumn
        anchors {
            fill: bg
        }
        spacing: units.gu(0.5)

        CoverGrid {
            id: coverGrid
            size: parent.width
        }

        Item {
            height: units.gu(.5)
            width: units.gu(1)
        }

        // Labels are ~1.5GU per line
        // We are limiting to 3 lines long
        // with the preference on the first label
        Label {
            id: primaryLabel
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
            }
            color: "#FFF"
            elide: Text.ElideRight
            fontSize: "small"
            opacity: 1.0
            maximumLineCount: 2
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Label {
            id: secondaryLabel
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
            }
            color: "#FFF"
            elide: Text.ElideRight
            fontSize: "small"
            // Allow wrapping of 2 lines unless primary has been wrapped
            maximumLineCount: primaryLabel.lineCount > 1 ? 1 : 2
            opacity: 0.4
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            height: units.gu(1) + cardColumn.spacing
            width: units.gu(1)
        }
    }

    /* Overlay for when card is pressed */
    Rectangle {
        id: overlay
        anchors {
            fill: bg
        }
        color: "#000"
        opacity: cardMouseArea.pressed ? 0.3 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: LomiriAnimation.FastDuration
            }
        }
    }

    /* Capture mouse events */
    MouseArea {
        id: cardMouseArea
        anchors {
            fill: parent
        }
        onClicked: card.clicked(mouse)
        onPressAndHold: card.pressAndHold(mouse)
    }
}
