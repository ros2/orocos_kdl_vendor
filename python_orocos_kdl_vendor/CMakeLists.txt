cmake_minimum_required(VERSION 3.7)

project(python_orocos_kdl_vendor)

find_package(ament_cmake REQUIRED)

option(FORCE_BUILD_VENDOR_PKG
  "Build python_orocos_kdl from source, even if system-installed package is available"
  OFF)

if(NOT FORCE_BUILD_VENDOR_PKG)
  # Check if Python bindings are installed by trying to import from interpreter
  # Figure out Python3 debug/release before anything else can find_package it
  if(WIN32 AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_package(python_cmake_module REQUIRED)
    find_package(PythonExtra REQUIRED)

    # Force FindPython3 to use the debug interpreter where ROS 2 expects it
    set(Python3_EXECUTABLE "${PYTHON_EXECUTABLE_DEBUG}")
  endif()
  find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
  execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import PyKDL"
    RESULT_VARIABLE pykdl_import_exit_code
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if(pykdl_import_exit_code EQUAL 0)
    set(pykdl_FOUND 1)
  endif()
endif()

macro(build_pykdl)
  set(extra_cmake_args)
  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()
  if(DEFINED CMAKE_TOOLCHAIN_FILE)
    list(APPEND extra_cmake_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
    if(ANDROID)
      if(DEFINED ANDROID_ABI)
        list(APPEND extra_cmake_args "-DANDROID_ABI=${ANDROID_ABI}")
      endif()
      if(DEFINED ANDROID_CPP_FEATURES)
        list(APPEND extra_cmake_args "-DANDROID_CPP_FEATURES=${ANDROID_CPP_FEATURES}")
      endif()
      if(DEFINED ANDROID_FUNCTION_LEVEL_LINKING)
        list(APPEND extra_cmake_args "-DANDROID_FUNCTION_LEVEL_LINKING=${ANDROID_FUNCTION_LEVEL_LINKING}")
      endif()
      if(DEFINED ANDROID_NATIVE_API_LEVEL)
        list(APPEND extra_cmake_args "-DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}")
      endif()
      if(DEFINED ANDROID_NDK)
        list(APPEND extra_cmake_args "-DANDROID_NDK=${ANDROID_NDK}")
      endif()
      if(DEFINED ANDROID_STL)
        list(APPEND extra_cmake_args "-DANDROID_STL=${ANDROID_STL}")
      endif()
      if(DEFINED ANDROID_TOOLCHAIN_NAME)
        list(APPEND extra_cmake_args "-DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}")
      endif()
    endif()
  else()
    list(APPEND extra_cmake_args "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
  endif()
  list(APPEND extra_cmake_args "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")
  list(APPEND extra_cmake_args "-DENABLE_TESTS=OFF")
  list(APPEND extra_cmake_args "-DENABLE_EXAMPLES=OFF")

  include(ExternalProject)

  # Build PyKDL
  externalproject_add(pykdl
    URL https://github.com/orocos/orocos_kinematics_dynamics/archive/e25a13fc5820dbca6b23d10506407bca9bcdd25f.zip
    URL_MD5 8ac40c9f84eca10dbe1f3777ba715ba0
    TIMEOUT 600
    SOURCE_SUBDIR python_orocos_kdl
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install
      ${extra_cmake_args}
  )

  # The external project will install to the build folder, but we'll install that on make install.
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}
    USE_SOURCE_PERMISSIONS
  )
endmacro()

if(NOT pykdl_FOUND)
  build_pykdl()
endif()

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
