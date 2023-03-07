/*
 * Copyright: 2020 UBports
 *
 *
 * reminders is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Lomiri.Components 1.3
import "../components"

Page {
    id: settingsPage

    header: PageHeader {
        title: i18n.tr("Settings")
        leadingActionBar {
            actions: backActionComponent
        }
        StyleHints {
            backgroundColor: mainView.headerColor
            dividerColor: Qt.darker(mainView.headerColor, 1.1)
        }
        Action {
            id: backActionComponent
            iconName: "back"
            objectName: "backAction"
            onTriggered: mainPageStack.pop()
        }
    }

    Flickable {
        id: settingsFlickable
        clip: true
        flickableDirection: Flickable.AutoFlickIfNeeded
        anchors {
            topMargin: settingsPage.header.height + units.gu(1)
            fill: parent
        }
        contentHeight: settingsColumn.childrenRect.height

        Column {
            id: settingsColumn
            anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
            }

            ListItem {
                id: displayOnItem
                height: displayOnLayout.height
                divider.visible: false
                ListItemLayout {
                    id: displayOnLayout
                    title.text: i18n.tr("Keep screen on while music is played")
                    Switch {
                        id: displayOnSwitch
                        SlotsLayout.position: SlotsLayout.Last
                        checked: startupSettings.keepDisplayOn
                        onCheckedChanged: {
                          startupSettings.keepDisplayOn = checked;
                        }
                    }
                }

                onClicked: displayOnSwitch.checked = !displayOnSwitch.checked;
            }
        }
    }
}
