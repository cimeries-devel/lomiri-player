# make the qml files visible on qtcreator
file(GLOB HELPERS_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

add_custom_target(music_ubports_HELPERS_QMLFiles ALL SOURCES ${HELPERS_QML_FILES})
