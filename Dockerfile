FROM ubuntu:jammy

RUN apt-get update && apt-get -y install mc gcc-9 g++-9 git python2 pkg-config libnetcdf-dev libhdf5-dev libglib2.0-dev libnetcdf-dev libxml2-dev vim
RUN mkdir -p /workspace

RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python2 100
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9

# Copy Expert Development source code (2024-01-19)
RUN mkdir -p /src
WORKDIR "/src"
#COPY src/XN5 /src/XN5
COPY src/XN5-2024-01-19.tar.gz /src
RUN tar -zxvf XN5-2024-01-19.tar.gz --directory /src/
RUN rm XN5-2024-01-19.tar.gz
WORKDIR "XN5/dev"
RUN ./waf --max_optimize --debug --USE_OPENMP configure
RUN ./waf build install

# Set executable rights for expertn_bin
RUN chmod 750 ../built/bin/expertn_bin

# copy Expert-N to personal opt directory
RUN mkdir -p /opt/XN5
RUN cp -Rp /src/XN5/* /opt/XN5

# Add the following lines to .bashrc
RUN echo 'export XPN_PATH="/opt/XN5"' >> ~/.bashrc
RUN echo '. $XPN_PATH/built/bin/expertn_environment.sh' >> ~/.bashrc

# Create workspace to share files with the containered environment
WORKDIR "/workspace"

# Start bash for interactive use 
CMD ["/bin/bash"]

