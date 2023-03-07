/*
 * Copyright (C) 2014, 2015, 2016
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
import QtQuick.LocalStorage 2.0
import Lomiri.Components 1.3
import "../../logic/meta-database.js" as Library

Action {
    iconName: "add"
    objectName: "addToQueueAction"
    text: i18n.tr("Add to Queue")

    onTriggered: {
        console.debug("Debug: Add track to queue: " + model)
        player.mediaPlayer.playlist.addItem(Qt.resolvedUrl(model.filename))
    }
}
