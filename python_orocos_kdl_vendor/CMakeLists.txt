cmake_minimum_required(VERSION 3.12)

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
  # Finding pybind11 first avoid a CMake warning about CMP0054 because the
  # minimum required version is greater than 3.1 in this file
  find_package(pybind11)

  include(FetchContent)

  # This version must match orocos_kdl_vendor exactly
  FetchContent_Declare(
    python_orocos_kdl
    URL https://github.com/orocos/orocos_kinematics_dynamics/archive/e25a13fc5820dbca6b23d10506407bca9bcdd25f.zip
    URL_MD5 8ac40c9f84eca10dbe1f3777ba715ba0
  )

  FetchContent_GetProperties(python_orocos_kdl)
  # TODO(sloretz) use FetchContent_MakeAvailable() when CMake 3.14 is the minimum
  if(NOT python_orocos_kdl_POPULATED)
    FetchContent_Populate(python_orocos_kdl)
    # Make python_orocos_kdl targets part of this project
    add_subdirectory(
      "${python_orocos_kdl_SOURCE_DIR}/python_orocos_kdl"
      ${python_orocos_kdl_BINARY_DIR})
  endif()

  find_package(ament_cmake_python REQUIRED)

  # Figure out where it installed the python module to
  get_directory_property(pykdl_install_dir
    DIRECTORY "${python_orocos_kdl_SOURCE_DIR}/python_orocos_kdl"
    DEFINITION PYTHON_SITE_PACKAGES_INSTALL_DIR)

  # Make an environment hook matching where it got installed
  set(_backup_PYTHON_INSTALL_DIR "${PYTHON_INSTALL_DIR}")
  set(PYTHON_INSTALL_DIR "${pykdl_install_dir}")
  _ament_cmake_python_register_environment_hook()
  set(PYTHON_INSTALL_DIR "${_backup_PYTHON_INSTALL_DIR}")
endmacro()

if(NOT pykdl_FOUND)
  message(STATUS "Did not find PyKDL installation, building from source")
  build_pykdl()
endif()

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
