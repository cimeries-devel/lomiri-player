# make the qml files visible on qtcreator
file(GLOB WALKTHROUGH_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

add_custom_target(music_ubports_WALKTHROUGH_QMLFiles ALL SOURCES ${WALKTHROUGH_QML_FILES})
