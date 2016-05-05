FROM fedora

MAINTAINER mocchi

ENV CC clang
# ql_proxy_url "http://192.168.1.1"
ENV ql_proxy_url (list)

RUN dnf -y install git make autoconf automake curl-devel clang tar bzip2 findutils sbcl

RUN echo 'compile sbcl' \
    && cd /tmp \
    && curl -OSL http://prdownloads.sourceforge.net/sbcl/sbcl-1.3.5-source.tar.bz2 \
    && tar jxf sbcl-1.3.5-source.tar.bz2 \
    && cd sbcl-1.3.5 \
    && sh make.sh \
    && sh install.sh \
    && echo 'install quicklisp' \
    && (curl -L http://beta.quicklisp.org/quicklisp.lisp && echo "(quicklisp-quickstart:install :proxy $ql_proxy_url)") | sbcl --no-userinit \
    &&  echo '(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))) (when (probe-file quicklisp-init) (load quicklisp-init)))' > /root/.sbclrc \
    && rm -rf /tmp/*

RUN echo "make swank script" \
    && mkdir -p /develop/.server \
    && cd  /develop/.server \
    && echo '(ql:quickload :swank)(exit)' | sbcl \
    && cat /root/.sbclrc > swank.lisp \
    && echo '(ql:quickload :swank)(setq swank::*loopback-interface* "0.0.0.0")(swank:create-server :dont-close t :style :spawn)(loop (sleep 2147483647))' >> swank.lisp

EXPOSE 4005

ENTRYPOINT /usr/local/bin/sbcl --script /develop/.server/swank.lisp
