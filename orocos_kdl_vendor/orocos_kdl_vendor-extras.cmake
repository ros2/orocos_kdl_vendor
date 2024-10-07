# Copyright 2022 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

find_package(orocos_kdl REQUIRED)
if(NOT TARGET orocos-kdl)
  find_library(orocos_kdl_LIBRARY orocos-kdl REQUIRED)
  add_library(orocos-kdl SHARED IMPORTED)
  set_target_properties(orocos-kdl PROPERTIES
    IMPORTED_LOCATION "${orocos_kdl_LIBRARY}"
    INTERFACE_LINK_LIBRARIES "${orocos_kdl_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${orocos_kdl_INCLUDE_DIRS}")
else()
  # TODO(clalancette): As of 2024-10-07, the orocos-kdl package in Conda does not properly
  # set the INTERFACE_INCLUDE_DIRECTORIES on the target, so downstream consumers cannot find
  # the headers.  Set this property if it has not already been set on the target.
  get_target_property(orocos_kdl_interface_include_dirs orocos-kdl INTERFACE_INCLUDE_DIRECTORIES)
  if(NOT orocos_kdl_interface_include_dirs)
    set_target_properties(orocos-kdl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${orocos_kdl_INCLUDE_DIRS}")
  endif()
endif()

find_package(eigen3_cmake_module REQUIRED)
find_package(Eigen3 REQUIRED)
message(STATUS "Ensuring Eigen3 include directory is part of orocos-kdl CMake target")
if(TARGET Eigen3::Eigen)
  # TODO: require target to exist when https://github.com/ros2/choco-packages/issues/19 is addressed
  target_link_libraries(orocos-kdl INTERFACE Eigen3::Eigen)
else()
  target_include_directories(orocos-kdl SYSTEM INTERFACE ${Eigen3_INCLUDE_DIRS})
endif()
