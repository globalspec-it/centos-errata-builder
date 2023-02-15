FROM nginx:mainline-alpine

LABEL creator Thomas HERBIN

ENV S3_URI = ""
ENV AWS_ACCESS_KEY_ID = ""
ENV AWS_SECRET_ACCESS_KEY = ""
ENV AWS_DEFAULT_REGION = ""

RUN   apk add --no-cache \
        python3 \
        py3-pip \
        py3-six \
        wget \
        && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
          createrepo_c \
      && pip3 install --no-cache-dir --upgrade pip \
      && pip3 install --no-cache-dir \
        awscli \
      && rm -rf /var/cache/apk/* ;

WORKDIR /tmp

COPY generate_updateinfo.py /tmp
COPY nginx-repo.conf /etc/nginx/conf.d/default.conf
COPY entrypoint /entrypoint

## Create Repo directories and remove index file to browse the server files freely
RUN mkdir /usr/share/nginx/html/errata5 \
          /usr/share/nginx/html/errata6 \
          /usr/share/nginx/html/errata7 \
          /usr/share/nginx/html/errata8 \
   && rm /usr/share/nginx/html/index.html