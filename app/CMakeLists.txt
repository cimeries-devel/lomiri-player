add_subdirectory(components)
add_subdirectory(graphics)
add_subdirectory(logic)
add_subdirectory(ui)

# make the qml files visible on qtcreator
file(GLOB APP_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
*.qml *.js *.png *.js *.json)

add_custom_target(music_ubports_APP_Files ALL SOURCES ${APP_FILES})
