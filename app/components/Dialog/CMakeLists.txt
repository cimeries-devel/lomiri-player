# make the qml files visible on qtcreator
file(GLOB DIALOG_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

add_custom_target(music_ubports_DIALOG_QMLFiles ALL SOURCES ${DIALOG_QML_FILES})
