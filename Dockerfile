# docker build . -t df && docker run --name df -it df
# docker cp data/ df:/opt/dwarffortress/df_linux/

FROM ubuntu:latest

RUN apt-get update 
RUN apt-get install -y curl tar bash xz-utils dwarf-fortress
RUN mkdir -p /opt/dwarffortress
RUN curl -L 'http://bay12games.com/dwarves/df_44_12_linux.tar.bz2' | tar -xjC /opt/dwarffortress
WORKDIR /opt/dwarffortress/df_linux
RUN sed -i -e 's/PRINT_MODE:2D/PRINT_MODE:TEXT/g' data/init/init.txt
RUN sed -i -e 's/INTRO:YES/INTRO:NO/g' data/init/init.txt
RUN sed -i -e 's/INITIAL_SAVE:NO/INITIAL_SAVE:YES/g' data/init/init.txt

CMD ["./df", "/bin/bash"]