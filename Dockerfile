FROM fedora:latest

RUN dnf -y --setopt=deltarpm=false install git perl "perl(Test::More)" "perl(Module::CPANfile)"

RUN dnf -y --setopt=deltarpm=false install "perl(List::Util)" \
"perl(YAML::Syck)" "perl(Tie::IxHash)" "perl(URI::Escape)"

RUN git clone https://github.com/hkoba/xhf-parser-conformance-test.git /tester && \
cd /tester && git submodule update --init

#========================================

ENTRYPOINT ["/tester/tester.t"]
