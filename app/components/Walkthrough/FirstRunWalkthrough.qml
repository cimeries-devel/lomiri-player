/*
 * Copyright (C) 2014, 2015
 *      Nekhelesh Ramananthan <nik90@ubuntu.com>
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
 *
 * Upstream location:
 * https://github.com/krnekhelesh/flashback
 */

import QtQuick 2.4
import Lomiri.Components 1.3

// Initial Walkthrough tutorial
Walkthrough {
    id: walkthrough
    objectName: "walkthroughPage"

    appName: "Music"

    onFinished: {
        walkthrough.visible = false
        mainPageStack.goBack()
        firstRun = false
    }

    model: [
        Slide1{},
        Slide2{},
        Slide3{}
    ]
}
