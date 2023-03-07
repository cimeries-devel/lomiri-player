# make the image files visible on qtcreator
file(GLOB IMAGE_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.png *.svg)

add_custom_target(music_ubports_IMAGEFiles ALL SOURCES ${IMAGE_FILES})
