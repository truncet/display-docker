FROM nvidia/cuda:12.4.1-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages

RUN apt-get update && apt-get install -y \
    x11-apps \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libx11-dev \
    xvfb \
    g++ \
    linux-headers-$(uname -r) \
    ubuntu-drivers-common \
    sudo
#RUN ubuntu-drivers install nvidia:555

RUN apt-get install -y x11-xserver-utils cuda
RUN apt-get install -y mesa-utils \
    libglvnd0 \
    libglvnd-dev 

# Create /etc/modprobe.d/blacklist.conf if it doesn't exist and disable unwanted drivers by blacklisting them
RUN touch /etc/modprobe.d/blacklist.conf && \
    echo "blacklist vga16fb" | tee -a /etc/modprobe.d/blacklist.conf && \
    echo "blacklist nouveau" | tee -a /etc/modprobe.d/blacklist.conf && \
    echo "blacklist rivafb" | tee -a /etc/modprobe.d/blacklist.conf && \
    echo "blacklist nvidiafb" | tee -a /etc/modprobe.d/blacklist.conf && \
    echo "blacklist rivatv" | tee -a /etc/modprobe.d/blacklist.conf

# Download and install the NVIDIA driver
COPY NVIDIA-Linux-x86_64-550.90.07.run /app/
RUN chmod +x /app/NVIDIA-Linux-x86_64-550.90.07.run
RUN /bin/sh /app/NVIDIA-Linux-x86_64-550.90.07.run --accept-license --ui=none --no-kernel-module --no-questions

# Copy xorg.conf to the correct location

# Set environment variables
ENV XDG_RUNTIME_DIR=/tmp/runtime
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64
ENV PATH=/usr/local/cuda/bin:$PATH
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV NVIDIA_VISIBLE_DEVICES=all

# Create runtime directory
RUN mkdir -p /tmp/runtime && chmod 700 /tmp/runtime

RUN apt-get install -y libglu1-mesa libegl1-mesa

# Copy the Unity application
COPY unityapp /app
COPY entrypoint.sh /app
RUN chmod +x /app/entrypoint.sh
COPY virtualgl_3.1_amd64.deb /app
RUN chmod +x /app/virtualgl_3.1_amd64.deb
RUN dpkg -i /app/virtualgl_3.1_amd64.deb


WORKDIR /app

# Ensure the Unity application is executable
RUN chmod +x new.x86_64

RUN nvidia-xconfig
#RUN X &
#RUN Xvfb :100 -screen 0 1024x768x24 +extension GLX +render -noreset &
COPY xorg.conf /etc/X11/xorg.conf
ENV DISPLAY=:100

#ENTRYPOINT ["sh", "-c", "tail",  "-f"]
ENTRYPOINT ["/app/entrypoint.sh"]

# Set the default command to run your application
CMD ["vglrun","-d", ":100","/app/new.x86_64"]

