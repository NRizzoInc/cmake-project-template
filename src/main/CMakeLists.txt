project(template-main-app)

SET(SOURCES
    main.cpp
)

SET(INCLUDES

)

add_executable(${PROJECT_NAME}
    ${SOURCES}
)

target_include_directories(${PROJECT_NAME}
    PRIVATE ${INCLUDES}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
)

finalize_binary(${PROJECT_NAME})

