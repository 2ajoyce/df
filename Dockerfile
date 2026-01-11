FROM ubuntu:22.04

LABEL maintainer="Dwarf Fortress Web"
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: moving to openbox for better compatibility
RUN apt-get update && apt-get install -y \
    curl bzip2 ca-certificates \
    libsdl2-2.0-0 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 \
    libgtk-3-0 libglu1-mesa libopenal1 libncursesw5 \
    libgl1-mesa-dri mesa-utils \
    xvfb x11vnc xdotool openbox \
    novnc websockify \
    dbus-x11 xfonts-base \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /opt/df

# Download and extract Dwarf Fortress
ARG DF_URL=https://www.bay12games.com/dwarves/df_53_09_linux.tar.bz2
RUN curl -L "${DF_URL}" | tar -xj

RUN chmod +x run_df dwarfort

# Configure DF: STANDARD mode
RUN if [ -f data/init/init.txt ]; then \
        sed -i "s/INTRO:YES/INTRO:NO/" data/init/init.txt; \
        sed -i "s/PRINT_MODE:2D/PRINT_MODE:STANDARD/" data/init/init.txt; \
    fi

# Startup script
RUN printf "#!/bin/bash\n\
rm -f /tmp/.X1-lock\n\
Xvfb :1 -screen 0 1280x800x24 -ac +extension GLX +render -noreset &\n\
export DISPLAY=:1\n\
export LIBGL_ALWAYS_SOFTWARE=1\n\
export GALLIUM_DRIVER=llvmpipe\n\
export SDL_RENDER_DRIVER=software\n\
export SDL_VIDEODRIVER=x11\n\
\n\
# Start DBUS\n\
export \$(dbus-launch)\n\
\n\
sleep 3\n\
openbox &\n\
sleep 2\n\
x11vnc -display :1 -forever -shared -nopw -bg -rfbport 5900 &\n\
/usr/bin/websockify --web /usr/share/novnc/ 6080 localhost:5900 &\n\
\n\
echo \"Launching Dwarf Fortress...\"\n\
# We run it and pipe output to catch errors\n\
./run_df 2>&1 | tee /opt/df/df_output.log\n" > /opt/df/start_df.sh && chmod +x /opt/df/start_df.sh

EXPOSE 6080

CMD ["/opt/df/start_df.sh"]
