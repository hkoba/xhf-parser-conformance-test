FROM fedora:24

RUN dnf -y --setopt=deltarpm=false install git perl "perl(Test::More)" "perl(Module::CPANfile)"

RUN dnf -y --setopt=deltarpm=false install "perl(List::Util)" \
"perl(YAML::Syck)" "perl(Tie::IxHash)" "perl(URI::Escape)"

RUN git clone https://github.com/hkoba/xhf-acceptance-inspection.git /tester && \
cd /tester && git submodule update --init

#========================================
RUN dnf -y --setopt=deltarpm=false install yum-utils

RUN rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"

RUN yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
dnf -y --setopt=deltarpm=false update

RUN dnf -y --setopt=deltarpm=false install fsharp mono-complete


# RUN cd /root && curl -O https://raw.githubusercontent.com/downloads/fsharp-editing/Forge/releases/download/1.3.2/forge.zip

COPY ./forge.zip /root



RUN mkdir /opt/forge && cd /opt/forge && unzip /root/forge.zip && ln -vnsf /opt/forge/forge.sh /usr/local/bin/forge

#========================================

ENTRYPOINT /tester/tester.t
