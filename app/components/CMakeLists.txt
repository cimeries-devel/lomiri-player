add_subdirectory(Delegates)
add_subdirectory(Dialog)
add_subdirectory(HeadState)
add_subdirectory(Helpers)
add_subdirectory(Flickables)
add_subdirectory(ListItemActions)
add_subdirectory(ViewButton)
add_subdirectory(Walkthrough)

# make the qml files visible on qtcreator
file(GLOB COMPONENTS_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

add_custom_target(music_ubports_COMPONENTS_QMLFiles ALL SOURCES ${COMPONENTS_QML_FILES})
