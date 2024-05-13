^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package orocos_kdl_vendor
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.5.1 (2024-05-13)
------------------
* Ensure that orocos_kdl_vendor doesn't accidentally find itself. (`#27 <https://github.com/ros2/orocos_kdl_vendor/issues/27>`_) (`#28 <https://github.com/ros2/orocos_kdl_vendor/issues/28>`_)
  When initially building the orocos_kdl_vendor package (on platforms
  where it actually builds), it turns out that it places a
  valid cmake configuration in the build directory.  In turn,
  that means that a subsequent rebuild will find this configuration
  in the build directory, and throw the rest of the logic off.
  This only seems to be a problem with CMake 3.29 and later, though
  I can't say exactly why at the moment.
  Workaround this problem by writing the configuration out to a
  temporary file, and then moving it into the final place with
  the final name.
  (cherry picked from commit 7aad6d1ad9fa54f3a48f1f194a85127e362c8ade)
  Co-authored-by: Chris Lalancette <clalancette@gmail.com>
* Contributors: mergify[bot]

0.5.0 (2024-01-24)
------------------
* Update to the latest orocos_kdl_kinematics commit. (`#25 <https://github.com/ros2/orocos_kdl_vendor/issues/25>`_)
* Contributors: Chris Lalancette

0.4.1 (2023-07-11)
------------------
* Switch to ament_cmake_vendor_package (`#20 <https://github.com/ros2/orocos_kdl_vendor/issues/20>`_)
* Contributors: Scott K Logan

0.4.0 (2023-04-27)
------------------

0.3.4 (2022-09-13)
------------------

0.3.3 (2022-06-24)
------------------
* Make sure to quote orocos variables when setting targets. (`#12 <https://github.com/ros2/orocos_kdl_vendor/issues/12>`_)
* Contributors: Chris Lalancette

0.3.2 (2022-06-21)
------------------
* Ensure orocos-kdl is available as a target (`#10 <https://github.com/ros2/orocos_kdl_vendor/issues/10>`_)
* Contributors: Scott K Logan

0.3.1 (2022-06-09)
------------------
* Ensure orocos-kdl target references Eigen (`#6 <https://github.com/ros2/orocos_kdl_vendor/issues/6>`_)
* Contributors: Scott K Logan

0.3.0 (2022-04-29)
------------------

0.2.2 (2022-04-08)
------------------

0.2.1 (2022-04-05)
------------------
* Add buildtool_depend on git (`#4 <https://github.com/ros2/orocos_kdl_vendor/issues/4>`_)
* Contributors: Scott K Logan

0.2.0 (2022-04-05)
------------------
* Install headers to include/${PROJECT_NAME} (`#3 <https://github.com/ros2/orocos_kdl_vendor/issues/3>`_)
* Contributors: Shane Loretz

0.1.0 (2022-04-04)
------------------
* Add vendor package for orocos_kdl (`#1 <https://github.com/ros2/orocos_kdl_vendor/issues/1>`_)
* Contributors: Jacob Perron, Shane Loretz
