# make the qml files visible on qtcreator
file(GLOB HEAD_STATE_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

add_custom_target(music_ubports_HEAD_STATE_QMLFiles ALL SOURCES ${HEAD_STATE_QML_FILES})
