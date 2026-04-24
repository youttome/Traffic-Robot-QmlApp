cmake_minimum_required(VERSION 3.16)

project(CircleBarsUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(DEFINED ENV{AMENT_PREFIX_PATH} AND NOT "$ENV{AMENT_PREFIX_PATH}" STREQUAL "")
    string(REPLACE ":" ";" AMENT_PREFIX_PATH_LIST "$ENV{AMENT_PREFIX_PATH}")
    list(PREPEND CMAKE_PREFIX_PATH ${AMENT_PREFIX_PATH_LIST})
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Core Gui)
find_package(OpenCV REQUIRED)
find_package(rclcpp QUIET)
find_package(sensor_msgs QUIET)
find_package(std_msgs QUIET)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

set(APP_HAS_ROS2 OFF)
if(rclcpp_FOUND AND sensor_msgs_FOUND AND std_msgs_FOUND)
    set(APP_HAS_ROS2 ON)
endif()

set(app_sources
    main.cpp
    systemmonitor.cpp
    systemmonitor.h
    camera.cpp
    camera.h
    datamanager.cpp
    datamanager.h
    rosstreammanager.cpp
    rosstreammanager.h
    include/topbarcontroller.h
    src/topbarcontroller.cpp
)

set(app_qml_files
    qml/Main.qml
    qml/Main50CircleBars.qml
    qml/CircleBar.qml
    qml/Top_Bar.qml
    qml/Main_window.qml
    qml/Arc_performance.qml
    qml/Left_Bar.qml
    qml/Bottom_Bar.qml
    qml/MapView.qml
    qml/monitor/BottomBar.qml
    qml/monitor/BottomBarRight.qml
    qml/monitor/CameraCard.qml
    qml/monitor/CameraNetwork.qml
    qml/monitor/HUDStatusBar.qml
    qml/monitor/MapIntelCard.qml
    qml/monitor/Monitor_window.qml
    qml/monitor/StreetAIPanel.qml
    qml/monitor/TrafficPanel.qml
)

set(app_resources
    qml/background.jpg
    qml/Qt-Development-white.png
    qml/monofonto.otf
)

qt_add_executable(appCircleBarsUI
    ${app_sources}
)

qt_add_qml_module(appCircleBarsUI
    URI CircleBarsUI
    VERSION 1.0
    QML_FILES
        ${app_qml_files}
    RESOURCES
        ${app_resources}
)

target_include_directories(appCircleBarsUI
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appCircleBarsUI PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appCircleBarsUI
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCircleBarsUI
    PRIVATE Qt6::Quick Qt6::Core Qt6::Gui
    PRIVATE ${OpenCV_LIBS}
)

target_compile_definitions(appCircleBarsUI
    PRIVATE APP_HAS_ROS2=$<BOOL:${APP_HAS_ROS2}>
)

if(APP_HAS_ROS2)
    target_link_libraries(appCircleBarsUI
        PRIVATE
            rclcpp::rclcpp
            sensor_msgs::sensor_msgs__rosidl_generator_cpp
            sensor_msgs::sensor_msgs__rosidl_typesupport_cpp
            std_msgs::std_msgs__rosidl_generator_cpp
            std_msgs::std_msgs__rosidl_typesupport_cpp
    )
endif()

include(GNUInstallDirs)
install(TARGETS appCircleBarsUI
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
