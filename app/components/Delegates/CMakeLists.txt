# make the qml files visible on qtcreator
file(GLOB DELEGATES_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

add_custom_target(music_ubports_DELEGATES_QMLFiles ALL SOURCES ${DELEGATES_QML_FILES})
