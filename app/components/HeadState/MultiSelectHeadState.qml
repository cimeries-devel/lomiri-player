/*
 * Copyright (C) 2015, 2016
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 * Copyright: 2020 UBports
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
import "../Flickables"

State {
    name: "selection"

    property bool addToQueue: true
    property MultiSelectListView listview
    property bool removable: false
    property PageHeader thisHeader: PageHeader {
        id: selectionState
        flickable: thisPage.flickable
        leadingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Cancel selection")
                    iconName: "back"
                    onTriggered: listview.closeSelection()
                }
            ]
        }
        title: thisPage.title
        trailingActionBar {
            actions: [
                Action {
                    iconName: listview.getSelectedIndices().length === listview.model.count ? "select-none" : "select"
                    text: i18n.tr("Select All")
                    onTriggered: {
                        if (listview.getSelectedIndices().length === listview.model.count) {
                            listview.clearSelection()
                        } else {
                            listview.selectAll()
                        }
                    }
                },
                Action {
                    iconName: "add-to-playlist"
                    text: i18n.tr("Add to playlist")
                    visible: listview !== null ? listview.getSelectedIndices().length > 0 : false
                    onTriggered: {
                        var items = []
                        var indicies = listview.getSelectedIndices();

                        for (var i=0; i < indicies.length; i++) {
                            items.push(makeDict(listview.model.get(indicies[i], listview.model.RoleModelData)));
                        }

                        mainPageStack.push(Qt.resolvedUrl("../../ui/AddToPlaylist.qml"),
                                           {"chosenElements": items})

                        listview.closeSelection()
                    }
                },
                Action {
                    iconName: "add"
                    text: i18n.tr("Add to queue")
                    visible: listview !== null ? (listview.getSelectedIndices().length > 0) && addToQueue: false

                    onTriggered: {
                        var items = [];
                        var indicies = listview.getSelectedIndices();

                        for (var i=0; i < indicies.length; i++) {
                            items.push(Qt.resolvedUrl(listview.model.get(indicies[i], listview.model.RoleModelData).filename));
                        }

                        player.mediaPlayer.playlist.addItems(items);

                        listview.closeSelection()
                    }
                },
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    visible: listview !== null ? (listview.getSelectedIndices().length > 0) && removable : false

                    onTriggered: {
                        removed(listview.getSelectedIndices())

                        listview.closeSelection()
                    }
                }
            ]
        }
        visible: thisPage.state === "selection"

        StyleHints {
            backgroundColor: mainView.headerColor
            dividerColor: Qt.darker(mainView.headerColor, 1.1)
        }
    }
    property Item thisPage

    signal removed(var selectedIndices)

    PropertyChanges {
        target: thisPage
        header: thisHeader
    }
}
