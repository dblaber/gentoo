# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
ROS_REPO_URI="https://github.com/ros-controls/ros_control"
KEYWORDS="~amd64"
ROS_SUBDIR=${PN}

inherit ros-catkin

DESCRIPTION="Interface for enforcing joint limits"
LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="
	dev-ros/roscpp
	dev-ros/hardware_interface
	dev-libs/urdfdom
	dev-ros/urdf
"
DEPEND="${RDEPEND}
	test? ( dev-ros/rostest dev-cpp/gtest )"
