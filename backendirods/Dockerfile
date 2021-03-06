
###################
FROM ubuntu:16.04

LABEL maintainer="Paolo D'Onorio De Meo <m.dantonio@cineca.it>"

###################
ARG RAPYDO_VERSION
RUN test -n "$RAPYDO_VERSION"

ARG CURRENT_UID
RUN test -n "$CURRENT_UID"

ARG CURRENT_GID
RUN test -n "$CURRENT_GID"
###################
# Install repository for python3.6+

ENV MYPYTHON_VERSION 3.8

RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common python-software-properties \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    bash less vim curl wget telnet iputils-ping git jq gosu build-essential \
    libkrb5-dev \
    python${MYPYTHON_VERSION} \
    python${MYPYTHON_VERSION}-dev \
    python${MYPYTHON_VERSION}-gdbm \
    python${MYPYTHON_VERSION}-distutils \
    python3-setuptools \
    libglobus-gssapi-gsi-dev libssl-dev libffi-dev \
    globus-proxy-utils \
    nginx \
    && ln -sf /usr/bin/python${MYPYTHON_VERSION} /usr/bin/python && ln -sf /usr/bin/python${MYPYTHON_VERSION} /usr/bin/python3 \
    && apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/*
###################
# PIP

RUN curl https://bootstrap.pypa.io/get-pip.py | python

# # DEBUG CONFLICTS:
# RUN pip install pip-conflict-checker && pipconflictchecker

# Latest requests-oauthlib [1.2.0] (required by Flask-OAuthlib)
# requires oauthlib<3.0.0,>=2.1.0
# Version 1.2.0 depends on OAuthlib 3.0.0 and above
# It does not support versions of OAuthlib before 3.0.0
# But Flask-OAuthlib depe nds from OAuthlib < 3.0.0
# gdapi-python == Python client for Rancher APIs
RUN pip3 install --upgrade --no-cache-dir dumb-init==1.2.2 Werkzeug==0.16.1 pytest-flask==1.0.0 pytest-cov==2.8.1 uwsgitop==0.11 oauthlib==2.1.0 requests-oauthlib==1.1.0 Flask-OAuthlib==0.9.5 git+https://github.com/EUDAT-B2STAGE/B2HANDLE.git@master git+https://github.com/irods/python-irodsclient.git@master gdapi-python==0.5.3 gssapi==1.5.1 git+https://github.com/rapydo/http-api.git@$RAPYDO_VERSION

###################
# Adding gsi as gssapi available mechanism for RPC
COPY gsi.conf /etc/gss/mech.d/
# main user for launching the apis
ENV APIUSER developer
# Emulating irods user creation. See http://j.mp/2lGPqlq

ENV APIUID $CURRENT_UID
RUN useradd \
    -r -M -d /home/$APIUSER -s /bin/bash -p ! \
    --uid $APIUID $APIUSER \
    && groupmod -og $CURRENT_GID $APIUSER \
    && mkdir -p /home/$APIUSER \
    && chown $APIUID:$CURRENT_GID /home/$APIUSER

###################
# UWSGI
ENV UWSGI_LOGS /var/log/uwsgi
ENV UWSGI_RUN /var/run/uwsgi
ENV MYUWSGI_HOME /tmp/uwsgi
RUN mkdir -p $UWSGI_LOGS
RUN mkdir -p $UWSGI_RUN
RUN chown -R www-data:www-data $UWSGI_LOGS $UWSGI_RUN

ENV UWSGI_MASTER ${MYUWSGI_HOME}/uwsgi_starter.ini
COPY uwsgi.ini ${UWSGI_MASTER}
COPY launch_uwsgi.sh /usr/local/bin/myuwsgi
COPY flask_migrate /usr/local/bin/flask_migrate 
RUN chmod +x /usr/local/bin/myuwsgi /usr/local/bin/flask_migrate

COPY nginx_base.conf /etc/nginx/nginx.conf
COPY nginx_uwsgi.conf /etc/nginx/sites-available/default

ENV PAGER less
ENV TERM=xterm-256color
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONIOENCODING="utf-8"
ENV FLASK_PORT 8080
ENV JWT_APP_SECRETS /jwts
ENV CODE_DIR /code
ENV CERTDIR /opt/certificates
ENV PYTHONPATH $CODE_DIR
EXPOSE $FLASK_PORT

ENV APIRC /home/$APIUSER/.bashrc
ENV FLASK_CMD "restapi launch"
RUN echo "echo\necho 'Launch the REST HTTP-API server with the command:'\necho '# $FLASK_CMD'" >> $APIRC && \
    echo "echo\necho 'Run unittests with:\n# restapi tests\n'\n" >> $APIRC && chown $APIUSER $APIRC

#### Make the terminal prettier ####
# generated with http://bashrcgenerator.com/
RUN echo 'export PS1="\\[\\033[38;5;11m\\]\\u\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\]@\\h:\\[$(tput sgr0)\\]\\[\\033[38;5;6m\\][\\w]:\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput sgr0)\\]"' >> /etc/bash.bashrc

# closing entrypoint

RUN mkdir $CODE_DIR
WORKDIR $CODE_DIR
RUN mkdir /docker-entrypoint.d/
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY ./docker-entrypoint-celery.sh /usr/local/bin/docker-entrypoint-celery

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["docker-entrypoint", "rest"]

# TODO: verify if better using tini for entrypoint
# https://github.com/krallin/tini-images
