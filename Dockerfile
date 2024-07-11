FROM ghcr.io/selkies-project/nvidia-glx-desktop:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update & apt-get  install -y x11-xserver-utils

# Create /etc/modprobe.d/blacklist.conf if it doesn't exist and disable unwanted drivers by blacklisting them
#RUN touch /etc/modprobe.d/blacklist.conf && \
#    echo "blacklist vga16fb" | tee -a /etc/modprobe.d/blacklist.conf && \
#    echo "blacklist nouveau" | tee -a /etc/modprobe.d/blacklist.conf && \
#    echo "blacklist rivafb" | tee -a /etc/modprobe.d/blacklist.conf && \
#    echo "blacklist nvidiafb" | tee -a /etc/modprobe.d/blacklist.conf && \
#    echo "blacklist rivatv" | tee -a /etc/modprobe.d/blacklist.conf
#
# Download and install the NVIDIA driver
COPY NVIDIA-Linux-x86_64-550.90.07.run /app/
RUN sudo chmod +x /app/NVIDIA-Linux-x86_64-550.90.07.run
RUN sudo /bin/sh /app/NVIDIA-Linux-x86_64-550.90.07.run --accept-license --ui=none --no-kernel-module --no-questions

# Copy xorg.conf to the correct location

# Set environment variables
ENV XDG_RUNTIME_DIR=/tmp/runtime
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64
ENV PATH=/usr/local/cuda/bin:$PATH
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV NVIDIA_VISIBLE_DEVICES=all

# Create runtime directory
RUN mkdir -p /tmp/runtime && chmod 700 /tmp/runtime


# Copy the Unity application
COPY unityapp /app
COPY entrypoint.sh /app
RUN sudo chmod +x /app/entrypoint.sh
RUN wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | \
  gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
COPY VirtualGL.list /etc/apt/sources.list.d/
RUN sudo apt-get update
RUN sudo apt-get install virtualgl
#RUN sudo dpkg -i /app/virtualgl_3.1_amd64.deb


WORKDIR /app

# Ensure the Unity application is executable
RUN sudo chmod +x new.x86_64

RUN nvidia-xconfig
RUN X &
RUN Xvfb :100 -screen 0 1024x768x24 +extension GLX +render -noreset &
COPY xorg.conf /etc/X11/xorg.conf
ENV DISPLAY=:100

#ENTRYPOINT ["sh", "-c", "tail",  "-f"]
ENTRYPOINT ["/bin/sh", "-c", "/app/entrypoint.sh"]

# Set the default command to run your application
#CMD ["vglrun","-d", ":100","/app/new.x86_64"]
CMD [ "/app/new.x86_64"]
#ENTRYPOINT ["/app/new.x86_64"]

