FROM ubuntu:14.04
MAINTAINER Evan Lezar evan.lezar@zalando.de

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git


# Create and archive path
ENV DATA_ROOT=/root/archive
RUN mkdir -p $DATA_ROOT

# Create a source path
ENV SRC_DIR=/root/src
RUN mkdir -p $SRC_DIR


WORKDIR /root

ADD * /root/experimenter/

# Clone the experimenter.
# RUN git clone https://github.com/elezar/experimenter.git

# Update the path.
ENV PATH=/root/experimenter:$PATH


RUN git config --global user.email "a@b.c"
RUN git config --global user.name "A B"



WORKDIR $SRC_DIR

CMD bash
