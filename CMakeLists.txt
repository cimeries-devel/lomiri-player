cmake_minimum_required(VERSION 3.5)
project(lomiri-music-app VERSION 3.0.2 LANGUAGES CXX)
include(FindGettext)
if(NOT GETTEXT_FOUND)
    message(FATAL_ERROR "Could not find gettext")
endif(NOT GETTEXT_FOUND)

# Standard install paths
include(GNUInstallDirs)

option(INSTALL_TESTS "Install the tests on make install" off)
option(CLICK_MODE "Installs to a contained location" on)

set(CLICK_NAME music.ubports)
set(APP_NAME music)
set(DESKTOP_FILE "${PROJECT_NAME}.desktop")
set(URLS_FILE "${CLICK_NAME}_${APP_NAME}.url-dispatcher")
set(APP_HARDCODE lomiri-music-app)
set(MAIN_QML app/music-app.qml)
set(ICON_FILE app/graphics/music-app.svg)
set(SPLASH_FILE app/graphics/music-app-splash.svg)
set(AUTOPILOT_DIR lomiri_music_app)
set(MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Tell QtCreator location and name of the manifest file")

if(CLICK_MODE)
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(DATA_DIR /)
    set(ICON ${ICON_FILE})
    set(SPLASH ${SPLASH_FILE})
    set(EXEC "qmlscene -qt5 ${MAIN_QML} --url=%u -I ./plugins")
    set(DESKTOP_DIR ${DATA_DIR})
    set(URLS_DIR ${DATA_DIR})

    configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json apparmor.json
            music-app-content.json DESTINATION ${CMAKE_INSTALL_PREFIX})
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
        DESTINATION ${DESKTOP_DIR})
    install(FILES ${URLS_FILE} DESTINATION ${URLS_DIR})
else(CLICK_MODE)
    set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${APP_HARDCODE})
    set(EXEC ${APP_HARDCODE})
    set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
    configure_file(${APP_HARDCODE}.in
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_HARDCODE})
    install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${APP_HARDCODE}
        DESTINATION ${CMAKE_INSTALL_BINDIR})
    set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)
    set(URLS_DIR ${CMAKE_INSTALL_DATADIR}/lomiri-url-dispatcher/urls)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
        DESTINATION ${DESKTOP_DIR})
    install(FILES music-app-content.json DESTINATION ${CMAKE_INSTALL_DATADIR}/content-hub/peers/ RENAME music-app)
    install(FILES ${URLS_FILE} DESTINATION ${URLS_DIR})
endif(CLICK_MODE)

file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml *.js *.png *.js)
install(DIRECTORY app DESTINATION ${DATA_DIR})
install(FILES ${SRC_FILES} ${ICON_FILE} DESTINATION ${DATA_DIR})

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)

add_custom_target(${DESKTOP_FILE} ALL
    COMMENT "Merging translations into ${DESKTOP_FILE}..."
    COMMAND ${GETTEXT_MSGFMT_EXECUTABLE}
            --desktop --template=${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}.in
            -o ${DESKTOP_FILE}
            -d ${CMAKE_SOURCE_DIR}/po
)

# Tests
enable_testing()

add_subdirectory(app)
add_subdirectory(po)
add_subdirectory(tests)

# make the qml files visible on qtcreator
file(GLOB QML_JS_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml *.js README* *.url-dispatcher *.txt)

add_custom_target(music_ubports_QMLFiles DEPENDS music-app.qml SOURCES ${QML_JS_FILES})
