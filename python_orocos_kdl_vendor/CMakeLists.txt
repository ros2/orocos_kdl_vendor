cmake_minimum_required(VERSION 3.20)

project(python_orocos_kdl_vendor)

find_package(ament_cmake REQUIRED)

option(FORCE_BUILD_VENDOR_PKG
  "Build python_orocos_kdl from source, even if system-installed package is available"
  OFF)

# Avoid DOWNLOAD_EXTRACT_TIMESTAMP warning for CMake >= 3.24
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

# By default, without the settings below, find_package(Python3) will attempt
# to find the newest python version it can, and additionally will find the
# most specific version.  For instance, on a system that has
# /usr/bin/python3.10, /usr/bin/python3.11, and /usr/bin/python3, it will find
# /usr/bin/python3.11, even if /usr/bin/python3 points to /usr/bin/python3.10.
# The behavior we want is to prefer the "system" installed version unless the
# user specifically tells us othewise through the Python3_EXECUTABLE hint.
# Setting CMP0094 to NEW means that the search will stop after the first
# python version is found.  Setting Python3_FIND_UNVERSIONED_NAMES means that
# the search will prefer /usr/bin/python3 over /usr/bin/python3.11.  And that
# latter functionality is only available in CMake 3.20 or later, so we need
# at least that version.
cmake_policy(SET CMP0094 NEW)
set(Python3_FIND_UNVERSIONED_NAMES FIRST)

if(NOT FORCE_BUILD_VENDOR_PKG)
  find_package(Python3 REQUIRED COMPONENTS Interpreter)
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
  include(FetchContent)

  # This version must match orocos_kdl_vendor exactly
  fetchcontent_declare(
    python_orocos_kdl
    URL https://github.com/orocos/orocos_kinematics_dynamics/archive/ce4bcb65a050615b6d7f21bc60fbb2656515791b.zip
    URL_MD5 f273799921a2fd21b79211c93fa67a5d
    UPDATE_DISCONNECTED TRUE
    PATCH_COMMAND
      ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> git apply -p1 --ignore-space-change --whitespace=nowarn
        ${CMAKE_CURRENT_SOURCE_DIR}/patches/0001-use-python3.patch
  )

  fetchcontent_makeavailable(python_orocos_kdl)
  add_subdirectory(
    "${python_orocos_kdl_SOURCE_DIR}/python_orocos_kdl"
    ${python_orocos_kdl_BINARY_DIR})

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
