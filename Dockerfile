FROM ros:melodic

# update
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install wget

# install cv and pcl tools for ros
RUN apt-get install ros-melodic-cv-bridge ros-melodic-pcl-conversions ros-melodic-tf ros-melodic-message-filters ros-melodic-image-transport* -y

# copy and run install scripts for ceres, eigen, and pcl
RUN mkdir $HOME/software
WORKDIR $HOME/software

# install opencv 3.4.16
COPY scripts/install_opencv.sh .
RUN chmod +x install_opencv.sh
RUN ./install_opencv.sh 3.4.16

# clone r3live
ENV ROS_WS $HOME/catkin_ws
RUN mkdir -p $ROS_WS/src
WORKDIR $ROS_WS
RUN git -C src clone https://github.com/zaalsabb/r3live.git
RUN git -C src clone https://github.com/zaalsabb/livox_ros_driver_for_R2LIVE.git

# install pcl-ros, eigen-conversions, and CGAL
RUN apt-get update
RUN apt-get install ros-melodic-pcl-ros -y
RUN apt-get install libcgal-dev pcl-tools -y
RUN apt-get install ros-melodic-eigen-conversions -y

# fix error with flann symbolic links
RUN mv /usr/include/flann/ext/lz4.h /usr/include/flann/ext/lz4.h.bak
RUN mv /usr/include/flann/ext/lz4hc.h /usr/include/flann/ext/lz4.h.bak
RUN ln -s /usr/include/lz4.h /usr/include/flann/ext/lz4.h
RUN ln -s /usr/include/lz4hc.h /usr/include/flann/ext/lz4hc.h

# install build tools
RUN apt-get update && apt-get install -y \
      python-catkin-tools \
      git \
    && rm -rf /var/lib/apt/lists/*

# build ros package source
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO && \
    catkin build \
      r3live

# HTTP PORT
EXPOSE 80

# setup ros environment
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "source $ROS_WS/devel/setup.bash" >> ~/.bashrc