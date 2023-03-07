/*
 * Copyright (C) 2013, 2014, 2015, 2016
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
import MediaScanner 0.1
import Lomiri.Thumbnailer 0.1
import QtQuick.LocalStorage 2.0
import "../logic/meta-database.js" as Library
import "../logic/playlists.js" as Playlists
import "../components"
import "../components/Delegates"
import "../components/Flickables"
import "../components/HeadState"


MusicPage {
    id: artistsPage
    objectName: "artistsPage"
    title: i18n.tr("Artists")
    searchable: true
    searchResultsCount: artistsModelFilter.count
    state: "default"
    states: [
        SearchableHeadState {
            thisPage: artistsPage
            searchEnabled: artistsModelFilter.count > 0
        },
        SearchHeadState {
            id: searchHeader
            thisPage: artistsPage
        }
    ]

    // Hack for autopilot otherwise Artists appears as MusicPage
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    MusicGridView {
        id: artistGridView
        itemWidth: units.gu(12)
        heightOffset: units.gu(7)
        model: SortFilterModel {
            id: artistsModelFilter
            property alias rowCount: artistsModel.rowCount
            model: ArtistsModel {
                id: artistsModel
                albumArtists: true
                store: musicStore
            }
            sort.property: "artist"
            sort.order: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            filter.property: "artist"
            filter.pattern: new RegExp(searchHeader.query, "i")
            filterCaseSensitivity: Qt.CaseInsensitive
        }
        delegate: Card {
            id: artistCard
            coverSources: [{art: "image://artistart/artist=" + model.artist + "&album="}]
            objectName: "artistsPageGridItem" + index
            primaryText: model.artist != "" ? model.artist : i18n.tr("Unknown Artist")
            secondaryTextVisible: false

            onClicked: {
                mainPageStack.push(Qt.resolvedUrl("ArtistView.qml"),
                                   {
                                       "artist": model.artist,
                                       "covers": artistCard.coverSources,
                                       "title": i18n.tr("Artist")
                                   })
            }
        }
    }
}

