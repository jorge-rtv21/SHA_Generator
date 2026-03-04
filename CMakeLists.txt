cmake_minimum_required(VERSION 3.16)

project(SHAGenerator VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup()

# Agregar el ejecutable principal
qt_add_executable(appSHAGenerator
    src/main.cpp
    src/ShaController.cpp src/ShaController.h
    src/ShaWorker.cpp src/ShaWorker.h
)

qt_add_qml_module(appSHAGenerator
    URI SHAGenerator
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/AboutDialog.qml
    RESOURCES
        assets/about.txt
)

target_link_libraries(appSHAGenerator
    PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick
)

# Configuración de instalación estándar de Qt CMake
install(TARGETS appSHAGenerator
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Establecer subsistema de Windows (oculta la consola)
set_target_properties(appSHAGenerator PROPERTIES WIN32_EXECUTABLE ON)
