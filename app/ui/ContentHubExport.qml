/*
 * Copyright (C) 2015, 2016
 *      Andrew Hayzen <ahayzen@gmail.com>
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
import Lomiri.Content 1.3
import MediaScanner 0.1
import Lomiri.Thumbnailer 0.1

import "../components"
import "../components/Delegates"
import "../components/Flickables"
import "../components/HeadState"


MusicPage {
    id: contentHubExportPage
    objectName: "contentHubExportPage"
    title: i18n.tr("Export Track")
    searchResultsCount: songsModelFilter.count
    showToolbar: false
    state: "default"
    states: [
        EmptyHeadState {
            thisHeader {
                leadingActionBar {
                    actions: [
                        Action {
                            iconName: "close"
                            onTriggered: {
                                transfer.items = [];
                                transfer.state = ContentTransfer.Aborted;

                                mainPageStack.pop()
                            }
                        }
                    ]
                }
                trailingActionBar {
                    actions: [
                        tickAction,
                        searchAction,
                    ]
                }
            }
            thisPage: contentHubExportPage
        },
        SearchHeadState {
            id: searchHeader
            thisHeader {
                trailingActionBar {
                    actions: [
                        tickAction,
                    ]
                }
            }
            thisPage: contentHubExportPage

            onQueryChanged: trackList.clearSelection()
        }
    ]
    transitions: [
        Transition {
            from: "search"
            to: "default"
            ScriptAction {
                script: trackList.clearSelection()
            }
        }
    ]


    Action {
        id: searchAction
        enabled: songsModelFilter.count > 0
        iconName: "search"
        onTriggered: {
            contentHubExportPage.state = "search"
            contentHubExportPage.header.contents.forceActiveFocus();
        }
    }
    Action {
        id: tickAction
        enabled: trackList.getSelectedIndices().length > 0
        iconName: "tick"
        onTriggered: {
            var items = [];
            var indicies = trackList.getSelectedIndices();

            for (var i=0; i < indicies.length; i++) {
                items.push(contentItemComponent.createObject(contentHubExportPage, {url: songsModelFilter.get(indicies[i]).filename}));
            }

            transfer.items = items;
            transfer.state = ContentTransfer.Charged;

            mainPageStack.pop()
        }
    }

    property var contentItemComponent
    property var transfer
    readonly property bool singular: transfer ? transfer.selectionType === ContentTransfer.Single : false

    MultiSelectListView {
        id: trackList
        anchors {
            bottomMargin: units.gu(2)
            fill: parent
            topMargin: units.gu(2)
        }
        model: SortFilterModel {
            id: songsModelFilter
            property alias rowCount: songsModel.rowCount
            model: SongsModel {
                id: songsModel
                store: musicStore
            }
            sort.property: "title"
            sort.order: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            filter.property: "title"
            filter.pattern: new RegExp(searchHeader.query, "i")
            filterCaseSensitivity: Qt.CaseInsensitive
        }
        ViewItems.selectMode: true

        property int selectedCache: -1

        delegate: MusicListItem {
            id: track
            objectName: "tracksPageListItem" + index
            height: units.gu(7)
            imageSource: {"art": model.art}
            multiselectable: true
            pressAndHoldEnabled: false  // Block PressAndHold from working
            subtitle {
                text: model.author
            }
            title {
                objectName: "tracktitle"
                text: model.title
            }

            onSelectedChanged: {
                if (singular) {
                    if (selected && (trackList.selectedCache === -1 || trackList.selectedCache !== index)) {
                        trackList.ViewItems.selectedIndices = [index];
                        trackList.selectedCache = index;
                    } else if (!selected && trackList.selectedCache === index) {
                        trackList.selectedCache = -1;
                    }
                }
            }
        }

        Component.onCompleted: state = "multiselectable"
    }
}
