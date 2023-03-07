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
import UserMetrics 0.1


Item {
    // UserMetrics to show Music stuff on welcome screen
    Metric {
        id: songsMetric
        name: "music-metrics"
        // TRANSLATORS: this refers to a number of tracks greater than one. The actual number will be prepended to the string automatically (plural forms are not yet fully supported in usermetrics, the library that displays that string)
        format: "<b>%1</b> " + i18n.tr("tracks played today")
        emptyFormat: i18n.tr("No tracks played today")
        domain: "lomiri-music-app"
    }

    // Connections for usermetrics
    Connections {
        id: userMetricPlayerConnection
        target: player.mediaPlayer

        property bool songCounted: false

        onPositionChanged: {
            // Increment song count on Welcome screen if song has been
            // playing for over 10 seconds.
            if (player.mediaPlayer.position > 10000 && !songCounted) {
                songCounted = true
                songsMetric.increment()
                console.debug("Increment UserMetrics")
            }
        }
    }

    Connections {
        target: player.mediaPlayer.playlist
        onCurrentIndexChanged: userMetricPlayerConnection.songCounted = false
        onCurrentItemSourceChanged: userMetricPlayerConnection.songCounted = false
    }
}
